import 'package:flutter/material.dart';
import '../../../models/activity_model.dart';
import '../../../models/lodging_model.dart';
import '../../../models/transportation_model.dart';
import '../../../models/trip_model.dart';

import 'activity_details.dart';
import 'lodging_details.dart';
import 'transportation_details.dart';

class DetailsPage extends StatelessWidget{

  final ActivityData activity;
  final LodgingData lodging;
  final TransportationData transport;
  final Trip trip;
  final String type;

  DetailsPage({this.activity,this.lodging,this.transport,this.type, this.trip});



  @override
  Widget build(BuildContext context) {
    switch (type){
      case 'Activity':
        return ActivityDetails(activity: activity,trip: trip,);
      case 'Lodging':
        return LodgingDetails(lodging:lodging,trip: trip,);
      default:
        return TransportationDetails(transport:transport,);
    }
  }

}





