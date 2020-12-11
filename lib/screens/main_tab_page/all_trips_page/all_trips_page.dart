import 'package:flutter/material.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/all_trips_new_design.dart';
import 'package:travelcrew/services/database.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';


class AllTripsPage extends StatefulWidget{


  AllTripsPage();

  @override
  _AllTripsPageState createState() => _AllTripsPageState();
}

class _AllTripsPageState extends State<AllTripsPage> {
  // final Geolocator geolocator = Geolocator();
  // GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  List<Trip> trip;

  // Position _currentPosition;
  // String _currentAddress;
  // String city;
  // String country;
  // String date;
  // String zipcode;
  // GeoPoint geoPoint;
  // bool hasLocation = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _getLocation().then((position) {
  //     _currentPosition = position;
  //     _getAddressFromLatLng();
  //     setState(() {
  //       hasLocation = true;
  //     });
  //   });
  //
  // }

  @override
  Widget build(BuildContext context) {
    // if(date != null){
    //   CloudFunction().addCurrentLocation(docID: date, city: city,country: country,zipcode: zipcode, geoPoint: geoPoint);
    // }
    return StreamProvider<List<Trip>>.value(
      value: DatabaseService().trips,
      child: StreamProvider<List<TripAds>>.value(
        value: DatabaseService().adList,
        child: Container (
          child: AllTripsNewDesign(),
        ),
      ),
    );
  }

  // Future<Position> _getLocation() async {
  //   var currentLocation;
  //   try {
  //     currentLocation = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);
  //   } catch (e) {
  //     currentLocation = null;
  //   }
  //   return currentLocation;
  // }
  //
  // _getAddressFromLatLng() async {
  //   try {
  //     List<Placemark> p = await placemarkFromCoordinates(
  //         _currentPosition.latitude, _currentPosition.longitude);
  //
  //     Placemark place = p[0];
  //
  //     var now = new DateTime.now();
  //     String formatter = DateFormat('yMd').add_H().format(now);
  //
  //     setState(() {
  //       _currentAddress =
  //       "${place.locality}, ${place.postalCode}, ${place.country}";
  //       city = place.locality.toString();
  //       country = place.country.toString();
  //       date = formatter.replaceAll('/', 'x').replaceAll(' ', 'x');
  //       zipcode = place.postalCode.toString();
  //       geoPoint = new GeoPoint(_currentPosition.latitude, _currentPosition.longitude);
  //     });
  //
  //
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}