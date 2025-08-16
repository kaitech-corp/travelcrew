class ContinentBox {

  ContinentBox(this.name, this.minLat, this.maxLat, this.minLng, this.maxLng);
  final String name;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  bool contains(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}

final List<ContinentBox> kContinentBoxes = [
  ContinentBox('N. America', 15.0, 72.0, -168.0, -52.0),
  ContinentBox('S. America', -56.0, 13.0, -81.0, -34.0),
  ContinentBox('Europe', 35.0, 71.0, -25.0, 45.0),
  ContinentBox('Africa', -35.0, 37.0, -17.0, 51.0),
  ContinentBox('Asia', 0.0, 81.0, 26.0, 180.0),
  ContinentBox('Oceania', -50.0, 0.0, 110.0, 180.0),
  ContinentBox('Antarctica', -90.0, -60.0, -180.0, 180.0),
];
