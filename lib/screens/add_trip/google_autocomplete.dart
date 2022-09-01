
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../models/custom_objects.dart';
import 'add_trip_page.dart';

/// Google places API
class GooglePlaces extends StatefulWidget{


  const GooglePlaces({required this.homeScaffoldKey, required this.searchScaffoldKey,required this.controller});

  final GlobalKey<ScaffoldState> homeScaffoldKey;
  final GlobalKey<ScaffoldState> searchScaffoldKey;
  final TextEditingController controller;

  @override
  _GooglePlacesState createState() => _GooglePlacesState();
}

class _GooglePlacesState extends State<GooglePlaces> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GooglePlaceAutoCompleteTextField(
          textEditingController: widget.controller,
          googleAPIKey: dotenv.env['kGoogleApiKey']!,
          debounceTime: 800, // default 600 ms,
          countries: const ['us','fr','mx','ca'],// optional by default null is set
          getPlaceDetailWithLatLng: (Prediction prediction) {
// this method will return latlng with place detail
            print('placeDetails${prediction.lng}');
          }, // this callback is called when isLatLngRequired is true
          itmClick: (Prediction prediction) {
            final double lat = prediction.lat as double;
            final double lng = prediction.lng as double;

            if (widget.controller.text.isEmpty) {
              widget.controller.text = prediction.description!;
            }
            myController.text= prediction.description!;
            googleData2.value = GoogleData(
              location: prediction.description,
              geoLocation: GeoPoint(lat, lng),
            );

            widget.controller.text=prediction.description!;
            widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
          }
      )
      ,
    );
    //   ElevatedButton(
    //   onPressed: _handlePressButton,
    //   child: const Text("Search"),
    // );
  }
}


