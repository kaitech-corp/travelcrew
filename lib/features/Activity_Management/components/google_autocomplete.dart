import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../services/database.dart';
import '../activity_form.dart';

/// Google places API
class GooglePlaces extends StatefulWidget {
  const GooglePlaces(
      {super.key,
      required this.homeScaffoldKey,
      required this.searchScaffoldKey,
      required this.controller});

  final GlobalKey<ScaffoldState> homeScaffoldKey;
  final GlobalKey<ScaffoldState> searchScaffoldKey;
  final TextEditingController controller;

  @override
  State<GooglePlaces> createState() => _GooglePlacesState();
}

class _GooglePlacesState extends State<GooglePlaces> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _handlePressButton(context);
      },
      child: const Text('Search'),
    );
  }
}

Future<void> _handlePressButton(BuildContext context) {
  return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          title: const Text(
            'Google Search',
            textScaleFactor: 1.5,
          ),
          content: GooglePlaceAutoCompleteTextField(
              textEditingController: locationController,
              googleAPIKey: dotenv.env['kGoogleApiKey']!,
              debounceTime: 800, // default 600 ms,
              // countries: const <String>[
              //   'us',
              //   'fr',
              //   'mx',
              //   'ca',
              //   'es'
              // ], // optional by default null is set
              getPlaceDetailWithLatLng: (Prediction prediction) {
                final double lat = double.parse(prediction.lat!);
                final double lng = double.parse(prediction.lng!);
                geopoint1.value = GeoPoint(lat, lng);
                // googleData.value = GoogleData(geoLocation: GeoPoint(lat, lng));
              }, // this callback is called when isLatLngRequired is true
              itmClick: (Prediction prediction) {
                if (prediction != null) {
                  locationController.text = prediction.description!;
                  locationController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description!.length));
                }
                navigationService.pop();
              }),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  navigationService.pop();
                },
                child: const Text('Done')),
            TextButton(
                onPressed: () {
                  locationController.text = '';
                },
                child: const Text('Clear'))
          ],
        );
      });
}
