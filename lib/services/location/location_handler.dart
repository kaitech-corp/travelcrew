import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import '../../models/location_model.dart';
import '../functions/cloud_functions.dart';
import 'geo_location_handler.dart';

class LocationHandler {

  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionStatus;
  late LocationData _locationData;

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
    final bool hasPermission = await getPermission();
      if(hasPermission == true) {
        _locationData = await location.getLocation();
        final LocationModel locationModel = await GeoLocationHandler().getAddressFromLatLng(GeoPoint(_locationData.latitude!,_locationData.longitude!));
        if(locationModel != null){
          if (kDebugMode) {
            print('Got here: ${locationModel.geoPoint?.longitude}');
          }
        CloudFunction().recordLocation(locationModel:locationModel);
        }
      }
  }
}
