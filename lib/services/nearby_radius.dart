import 'dart:math' as math;

/// A latitude query bound followed by an exact spherical-distance check.
/// Longitude is checked after the query so date-line and polar searches work.
class NearbyRadius {
  static const double earthRadiusKm = 6371.0088;

  static double latitudeDelta(int radiusKm) {
    if (radiusKm < 1 || radiusKm > 1000) {
      throw const FormatException('Nearby radius must be 1–1000 km.');
    }
    return radiusKm / earthRadiusKm * 180 / math.pi;
  }

  static bool contains({
    required double centerLatitude,
    required double centerLongitude,
    required double latitude,
    required double longitude,
    required int radiusKm,
  }) {
    latitudeDelta(radiusKm);
    if (!_valid(centerLatitude, centerLongitude) ||
        !_valid(latitude, longitude)) {
      return false;
    }
    final latitudeDifference = _radians(latitude - centerLatitude);
    final longitudeDifference = _radians(longitude - centerLongitude);
    final a =
        math.pow(math.sin(latitudeDifference / 2), 2) +
        math.cos(_radians(centerLatitude)) *
            math.cos(_radians(latitude)) *
            math.pow(math.sin(longitudeDifference / 2), 2);
    final distance =
        2 * earthRadiusKm * math.asin(math.sqrt(a.clamp(0.0, 1.0)));
    return distance <= radiusKm;
  }

  static bool _valid(double latitude, double longitude) =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  static double _radians(double degrees) => degrees * math.pi / 180;
}
