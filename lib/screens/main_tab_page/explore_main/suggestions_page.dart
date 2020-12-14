import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/screens/add_trip/add_trip_page.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../../loading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';


class SuggestionsPage extends StatefulWidget{


  @override
  _SuggestionsPageState createState() => _SuggestionsPageState();
}


class _SuggestionsPageState extends State<SuggestionsPage> {
  
  final Geolocator geolocator = Geolocator();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  List<PlaceDetails> _detailedPlaces = [];

  Position _currentPosition;
  String _currentAddress;
  String city;
  String country;
  String date;
  String zipcode;
  GeoPoint geoPoint;
  String place;

  bool hasLocation = false;

  @override
  void initState() {
    super.initState();
    _getLocation().then((position) {
      _currentPosition = position;
      _getAddressFromLatLng();
      setState(() {
        hasLocation = true;
      });
    });

  }

  bool showWidget(){
    if(place?.isNotEmpty ?? false){
      return true;
    } else {
      return false;
    }
  }

  void updatePlace(String placetype){
    setState(() {
      place = placetype;
    });
  }

  Future<List<PlaceDetails>> googleNearbyPlaces() async {
    if(showWidget()){
      dynamic _location = TCFunctions()
          .getLocation(_currentPosition.latitude, _currentPosition.longitude);
      var results = await _places.searchNearbyWithRadius(_location, 10000,
          keyword: place);

      var len = results.results.length;
      results.results.forEach((item) async {
        var _value = await _places.getDetailsByPlaceId(item.placeId);
        // print(_value.result.formattedAddress);
        // _detailedPlaces.insert(0, _value.result);
        _detailedPlaces.add(_value.result);
        // print(_detailedPlaces.length);
      });
      // print(_detailedPlaces.length);
      // return _detailedPlaces.sublist(0, (len - 1));
      return _detailedPlaces;
    } else {

      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    if(date != null){
      CloudFunction().addCurrentLocation(docID: date, city: city,country: country,zipcode: zipcode, geoPoint: geoPoint);
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(spaceImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                style: Theme.of(context).textTheme.headline3,
                children: [
                  TextSpan(text: 'Nearby',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: " Suggestions",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent,fontSize: 28))
                ]
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            height: SizeConfig.screenHeight*.05,
            width: SizeConfig.screenWidth,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: placeTypes.length,
              itemBuilder: (context, index){
                final String placetype = placeTypes[index].toUpperCase();
                return RaisedButton(
                  color: Color(0x00000000),
                  textColor: (placetype == place) ? Colors.blue : Colors.white,
                  autofocus: true,
                  // clipBehavior: Clip.hardEdge,
                  splashColor: Colors.blue,
                  onPressed: (){
                    // if (place != placetype) {
                      updatePlace(placetype);
                    // }
                    // googleNearbyPlaces(place);
                    if(_currentPosition == null){
                      TravelCrewAlertDialogs().suggestionPageAlert(context);
                    }
                  },
                    child: Text('$placetype ',style: TextStyle(fontSize: 24))
                );
              },
            ),
          ),
          // showWidget() ?
          Expanded(
            child: FutureBuilder(
              builder: (context, places) {
                if(places.hasData) {
                  return ListView.builder(
                    itemCount: places.data.length,
                    itemBuilder: (context, index) {
                      print(places.data.length);
                      PlaceDetails place = places.data[index];
                    return Card(
                      child: InkWell(
                        splashColor: Colors.blueAccent,
                        onTap: (){
                          TCFunctions().launchURL(place.website);
                        },
                        child: ListTile(
                          title: Text('${place.name}', style: TextStyle(fontSize: 24, color: Colors.black),),
                          subtitle: Text('Address: ${place.formattedAddress}', style: TextStyle(fontSize: 12, color: Colors.black),),
                          trailing: IconButton(
                            icon: Icon(Icons.post_add),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AddTripPage(addedLocation: place.formattedAddress,)),);
                            },
                          ),
                        ),
                      ),
                    );
                    },
                  );
                } else {
                  return Loading();
                }
              },
              future: googleNearbyPlaces(),
            ),
          )
              // : Container(),
        ],
      ),
    );
  }


  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      var now = new DateTime.now();
      String formatter = DateFormat('yMd').add_H().format(now);

      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
        city = place.locality.toString();
        country = place.country.toString();
        date = formatter.replaceAll('/', 'x').replaceAll(' ', 'x');
        zipcode = place.postalCode.toString();
        geoPoint = new GeoPoint(_currentPosition.latitude, _currentPosition.longitude);
      });


    } catch (e) {
      print(e);
    }
  }
}


