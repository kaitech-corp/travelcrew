// import 'dart:async';
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:travelcrew/models/custom_objects.dart';
// import 'package:travelcrew/screens/add_trip/add_trip_page.dart';
// import 'package:travelcrew/services/constants/constants.dart';
//
//
//
// GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
//
// class GooglePlaces extends StatefulWidget{
//
//   final GlobalKey<ScaffoldState> homeScaffoldKey;
//   final GlobalKey<ScaffoldState> searchScaffoldKey;
//
//
//   GooglePlaces({this.homeScaffoldKey, this.searchScaffoldKey});
//
//   @override
//   _GooglePlacesState createState() => _GooglePlacesState();
// }
//
// class _GooglePlacesState extends State<GooglePlaces> {
//
//   Mode _mode = Mode.overlay;
//   @override
//   Widget build(BuildContext context) {
//     return RaisedButton(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//                 onPressed: _handlePressButton,
//                 child: const Text("Search"),
//               );
//   }
//
//   void onError(PlacesAutocompleteResponse response) {
//     widget.homeScaffoldKey.currentState.showSnackBar(
//       SnackBar(content: Text(response.errorMessage)),
//     );
//   }
//
//   Future<void> _handlePressButton() async {
//     // show input autocomplete with selected mode
//     // then get the Prediction selected
//     Prediction p = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: kGoogleApiKey,
//       onError: onError,
//       mode: _mode,
//       language: "en",
//       // components: [
//       //   Component(Component.country, "usa")],
//     );
//
//     displayPrediction(p, widget.homeScaffoldKey.currentState);
//
//   }
//
//   Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
//
//     if (p != null) {
//       // get detail (lat/lng)
//
//       PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
//       // print(detail.result.formattedAddress);
//       final lat = detail.result.geometry.location.lat;
//       final lng = detail.result.geometry.location.lng;
//
//       myController.text= detail.result.formattedAddress;
//       googleData2.value = GoogleData(
//         location: detail.result.formattedAddress,
//         geoLocation: new GeoPoint(lat, lng),
//       );
//
//     }
//   }
//
// }
//
//
//
// // custom scaffold that handle search
// // basically your widget need to extends [GooglePlacesAutocompleteWidget]
// // and your state [GooglePlacesAutocompleteState]
//
//
// class Uuid {
//   final Random _random = Random();
//
//   String generateV4() {
//     // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
//     final int special = 8 + _random.nextInt(4);
//
//     return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
//         '${_bitsDigits(16, 4)}-'
//         '4${_bitsDigits(12, 3)}-'
//         '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
//         '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
//   }
//
//   String _bitsDigits(int bitCount, int digitCount) =>
//       _printDigits(_generateBits(bitCount), digitCount);
//
//   int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);
//
//   String _printDigits(int value, int count) =>
//       value.toRadixString(16).padLeft(count, '0');
// }
//
