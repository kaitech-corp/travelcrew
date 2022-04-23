import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/location_model.dart';
import 'package:travelcrew/services/analytics_service.dart';

class GeoLocationHandler {

  // GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['kGoogleApiKey']);

  String city;
  String country;
  String date;
  String zipcode;
  GeoPoint geoPoint;
  String place;

  bool hasLocation = false;


  Future<LocationModel> getAddressFromLatLng(GeoPoint geoPoint) async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          geoPoint.latitude, geoPoint.longitude);

      Placemark place = p[0];

      var now = new DateTime.now();
      String formatter = DateFormat('yMd').add_H().format(now);

      city = place.locality.toString();
      country = place.country.toString();
      date = formatter.replaceAll('/', 'x').replaceAll(' ', 'x').toString();
      zipcode = place.postalCode.toString();

      return LocationModel(
          city: city,country: country,documentID: date, geoPoint: geoPoint,zipcode: zipcode);

    } catch (e) {
      AnalyticsService().writeError(e.toString());
      return LocationModel();
    }
  }
}