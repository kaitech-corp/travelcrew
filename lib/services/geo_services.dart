import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/app_strings_keys.dart';

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
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static Future<Placemark> getPlacemark() async {
    final Position position = await determinePosition();
    final List<Placemark> placemarks = await placemarkFromCoordinates(
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
      return LatLng(location['lat'] as double, location['lng'] as double);
    } else {
      throw Exception('Failed to fetch location');
    }
  }

  static Future<List<Map<String, String>>> fetchSuggestions(
    String input,
  ) async {
    final List<Map<String, String>> suggestions = [];
    try {
      if (input.isEmpty) return [];
      final String request =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleMapKey';
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        for (final element in json['predictions']) {
          suggestions.add({
            'place_id': element['place_id'] as String,
            'description': element['description'] as String,
          });
        }
        return suggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return suggestions;
  }

  static Future<List<Map<String, String>>> fetchPlaceSuggestions(
    String input, {
    String? type,
  }) async {
    final List<Map<String, String>> suggestions = [];
    try {
      if (input.isEmpty) return [];
      String request =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGoogleMapKey';
      if (type != null) {
        request += '&types=$type';
      }
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        for (final element in json['predictions']) {
          suggestions.add({
            'place_id': element['place_id'] as String,
            'description': element['description'] as String,
          });
        }
        return suggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return suggestions;
  }

  static Future<String> getAddress(double lat, double long) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      long,
    );
    return '${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}, ${placemarks[0].country}';
  }

  static Future<String> getCountryCode(double lat, double long) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      long,
    );
    return placemarks[0].isoCountryCode!;
  }

  static Future<String> getCity(double lat, double long) async {
    final List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      long,
    );
    return placemarks[0].locality!;
  }

  static Future getLocationDetailsFromPlaceId(String placeId) async {
    try {
      final String request =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$kGoogleMapKey';
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return json;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
