import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/services/nearby_radius.dart';

void main() {
  test('100 km latitude window is about 0.9 degrees', () {
    expect(NearbyRadius.latitudeDelta(100), closeTo(0.8993, 0.002));
  });

  test('nearby distance includes trips beyond the old 10 km window', () {
    bool near(double latitude, double longitude) => NearbyRadius.contains(
      centerLatitude: 37.7749,
      centerLongitude: -122.4194,
      latitude: latitude,
      longitude: longitude,
      radiusKm: 100,
    );

    expect(near(37.3382, -121.8863), isTrue); // San Jose
    expect(near(38.5816, -121.4944), isFalse); // Sacramento
  });

  test('date-line and polar longitude differences use geographic distance', () {
    expect(
      NearbyRadius.contains(
        centerLatitude: 0,
        centerLongitude: 179.8,
        latitude: 0,
        longitude: -179.8,
        radiusKm: 100,
      ),
      isTrue,
    );
    expect(
      NearbyRadius.contains(
        centerLatitude: 89,
        centerLongitude: 0,
        latitude: 89,
        longitude: 90,
        radiusKm: 200,
      ),
      isTrue,
    );
  });

  test('invalid coordinates and radius cannot produce false matches', () {
    expect(
      NearbyRadius.contains(
        centerLatitude: 0,
        centerLongitude: 0,
        latitude: double.nan,
        longitude: 0,
        radiusKm: 100,
      ),
      isFalse,
    );
    expect(() => NearbyRadius.latitudeDelta(0), throwsFormatException);
    expect(() => NearbyRadius.latitudeDelta(1001), throwsFormatException);
  });
}
