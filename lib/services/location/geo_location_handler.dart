import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../models/location_model/location_model.dart';

class GeoLocationHandler {
  // GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['kGoogleApiKey']);

  late String city;
  late String country;
  late String date;
  late String zipcode;
  late GeoPoint geoPoint;
  late String place;

  bool hasLocation = false;

  Future<LocationModel> getAddressFromLatLng(GeoPoint geoPoint) async {
    try {
      final List<Placemark> p =
          await placemarkFromCoordinates(geoPoint.latitude, geoPoint.longitude);

      final Placemark place = p[0];

      final DateTime now = DateTime.now();
      final String formatter = DateFormat('yMd').add_H().format(now);

      city = place.locality.toString();
      country = place.country.toString();
      // ignore: noop_primitive_operations
      date = formatter.replaceAll('/', 'x').replaceAll(' ', 'x').toString();
      zipcode = place.postalCode.toString();

      return LocationModel(
          city: city,
          country: country,
          documentID: date,
          geoPoint: geoPoint.toString(),
          zipcode: zipcode);
    } catch (e) {
      return LocationModel();
    }
  }
}
