import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/app_strings.dart';

class GeoServices {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<Placemark> getPlacemark() async {
    Position position = await determinePosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    return placemarks[0];
  }

  static Future<LatLng> getLatLngFromPlace(String place) async {
    final String request =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$place&key=$kGoogleMapKey';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      throw Exception('Failed to fetch location');
    }
  }

  static Future<List<Map<String, String>>> fetchSuggestions(
    String input,
  ) async {
    List<Map<String, String>> suggestions = [];
    try {
      if (input.isEmpty) return [];
      final String request =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleMapKey';
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        for (var element in json['predictions']) {
          suggestions.add({
            'place_id': element['place_id'],
            'description': element['description'],
          });
        }
        return suggestions;
      }
    } catch (e) {
      print(e);
    }
    return suggestions;
  }

  static Future<String> getAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}";
  }

  static Future<String> getCountryCode(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return placemarks[0].isoCountryCode!;
  }

  static Future<String> getCity(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return placemarks[0].locality!;
  }

  static getLocationDetailsFromPlaceId(String placeId) async {
    try {
      final String request =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleMapKey';
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return json;
      }
    } catch (e) {}
    return null;
  }
}
