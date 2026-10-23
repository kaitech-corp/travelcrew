import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_crew/services/geo_services.dart';

void main() {
  setUpAll(
    () => dotenv.loadFromString(envString: 'GOOGLE_MAPS_API_KEY=test-key'),
  );
  test(
    'selected destination uses its place ID and accepts integer coordinates',
    () async {
      final location = await GeoServices.getLatLngFromPlace(
        'Paris',
        placeId: 'selected-place',
        client: MockClient((request) async {
          expect(request.url.host, 'places.googleapis.com');
          expect(request.url.path, '/v1/places/selected-place');
          expect(request.headers['X-Goog-FieldMask'], 'location');
          return http.Response(
            jsonEncode({
              'location': {'latitude': 48, 'longitude': 2},
            }),
            200,
          );
        }),
      );
      expect(location.latitude, 48.0);
      expect(location.longitude, 2.0);
    },
  );
  test(
    'MCP text-only destinations use encoded geocoding, never the editor sentinel as a place ID',
    () async {
      final location = await GeoServices.getLatLngFromPlace(
        'Trinidad & Tobago',
        placeId: 'existing_location',
        client: MockClient((request) async {
          expect(request.url.queryParameters['address'], 'Trinidad & Tobago');
          expect(request.url.host, 'maps.googleapis.com');
          return http.Response(
            jsonEncode({
              'status': 'OK',
              'results': [
                {
                  'geometry': {
                    'location': {'lat': 10, 'lng': -61},
                  },
                },
              ],
            }),
            200,
          );
        }),
      );
      expect(location.longitude, -61.0);
    },
  );
  test(
    'empty results and rejected geocoding return useful errors instead of range errors',
    () async {
      for (final status in [
        'ZERO_RESULTS',
        'REQUEST_DENIED',
        'OVER_QUERY_LIMIT',
        'OK',
      ]) {
        await expectLater(
          GeoServices.getLatLngFromPlace(
            'Unknown',
            client: MockClient(
              (_) async => http.Response(
                jsonEncode({'status': status, 'results': []}),
                200,
              ),
            ),
          ),
          throwsA(isA<FormatException>()),
        );
      }
    },
  );
  test(
    'failed or missing place coordinates never become zero coordinates',
    () async {
      for (final response in [
        http.Response('{}', 403),
        http.Response('{}', 200),
        http.Response('{"location":{"latitude":91,"longitude":0}}', 200),
      ]) {
        await expectLater(
          GeoServices.getLatLngFromPlace(
            'Place',
            placeId: 'selected-place',
            client: MockClient((_) async => response),
          ),
          throwsA(isA<FormatException>()),
        );
      }
    },
  );
}
