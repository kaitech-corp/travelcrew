import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class AddTripEvent extends Equatable {
  @override
  List<Object?> get props => <Object?>[];
}

class AddTripNameChange extends AddTripEvent {

  AddTripNameChange({this.tripName});
  final String? tripName;

  @override
  List<Object> get props => <Object>[tripName!];
}

class AddTripTypeChanged extends AddTripEvent {

  AddTripTypeChanged({required this.travelType});
  final String? travelType;

  @override
  List<Object> get props => <Object>[travelType!];
}
class AddTripImageAdded extends AddTripEvent {

  AddTripImageAdded({required this.urlToImage});
  final File? urlToImage;

  @override
  List<Object> get props => <Object>[urlToImage!];
}


class AddTripButtonPressed extends AddTripEvent {

  AddTripButtonPressed(this.comment, this.endDate, this.endDateTimestamp, this.startDateTimestamp, this.ispublic, this.location, this.startDate, this.tripGeoPoint, this.urlToImage, {required this.tripName, required this.travelType});
  final String tripName;
  final String travelType;
  final String comment;
  final String endDate;
  final Timestamp endDateTimestamp;
  final Timestamp startDateTimestamp;
  final bool ispublic;
  final String location;
  final String startDate;
  final GeoPoint? tripGeoPoint;
  final File? urlToImage;
  

  @override
  List<Object?> get props => <Object?>[tripName, travelType,comment,endDate,endDateTimestamp,startDateTimestamp,startDate,ispublic,location,tripGeoPoint,urlToImage];
}
