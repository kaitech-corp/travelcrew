import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:travelcrew/models/location_model.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/location/geo_location_handler.dart';

class LocationHandler {

  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionStatus;
  LocationData _locationData;

  Future<void> enableLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
  }

  Future<bool> getPermission() async {
    _permissionStatus = await location.hasPermission();
    if(_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if(_permissionStatus == PermissionStatus.granted || _permissionStatus == PermissionStatus.grantedLimited){
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> getLocationData() async {
    bool hasPermission = await getPermission();
      if(hasPermission == true) {
        _locationData = await location.getLocation();
        LocationModel locationModel = await GeoLocationHandler().getAddressFromLatLng(GeoPoint(_locationData.latitude,_locationData.longitude));
        if(locationModel != null){
          print('Got here: ${locationModel.geoPoint.longitude}');
        CloudFunction().recordLocation(locationModel:locationModel);
        }
      }
  }
}

