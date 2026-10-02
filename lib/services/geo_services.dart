import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../utils/app_strings_keys.dart';

class GeoServices {
  static const String _newBaseUrl = 'https://places.googleapis.com/v1';

  static Map<String, String> _getHeaders({String? fieldMask}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': kGoogleMapKey,
    };
    if (fieldMask != null) {
      headers['X-Goog-FieldMask'] = fieldMask;
    }
    return headers;
  }

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

      final response = await http.post(
        Uri.parse('$_newBaseUrl/places:autocomplete'),
        headers: _getHeaders(),
        body: jsonEncode({'input': input}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['suggestions'] != null) {
          for (final element in json['suggestions']) {
            final prediction = element['placePrediction'];
            if (prediction != null) {
              suggestions.add({
                'place_id': prediction['placeId'] as String,
                'description': prediction['text']['text'] as String,
              });
            }
          }
        }
        return suggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in fetchSuggestions: $e');
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

      final Map<String, dynamic> body = {'input': input};
      if (type != null) {
        body['includedPrimaryTypes'] = [type];
      }

      final response = await http.post(
        Uri.parse('$_newBaseUrl/places:autocomplete'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['suggestions'] != null) {
          for (final element in json['suggestions']) {
            final prediction = element['placePrediction'];
            if (prediction != null) {
              suggestions.add({
                'place_id': prediction['placeId'] as String,
                'description': prediction['text']['text'] as String,
              });
            }
          }
        }
        return suggestions;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in fetchPlaceSuggestions: $e');
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

  /// Returns the place details from the New Places API.
  /// The response format follows the New Places API structure.
  static Future<Map<String, dynamic>?> getLocationDetailsFromPlaceId(
    String placeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_newBaseUrl/places/$placeId'),
        headers: _getHeaders(
          fieldMask: 'id,displayName,location,photos,formattedAddress',
        ),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getLocationDetailsFromPlaceId: $e');
      }
    }
    return null;
  }

  /// Generates a photo URL for the New Places API.
  /// [photoName] is the resource name returned in the 'photos' array (e.g., 'places/PLACE_ID/photos/PHOTO_ID').
  static String getPhotoUrl(String? photoName, {int maxWidth = 800}) {
    if (photoName == null || photoName.isEmpty) return '';
    final params =
        Uri(
          queryParameters: {
            'name': photoName,
            'maxWidthPx': maxWidth.toString(),
          },
        ).query;
    return '$kTravelCrewWebBaseUrl/api/place-photo?$params';
  }
}
