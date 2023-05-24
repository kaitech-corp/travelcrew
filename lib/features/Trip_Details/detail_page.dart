import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/lodging_model.dart';
import '../../../models/transportation_model.dart';
import '../../../models/trip_model.dart';
import '../Activities/activity_details.dart';
import '../Lodging/lodging_details.dart';
import '../Transportation/transportation_details.dart';


class DetailsPage extends StatelessWidget{

  const DetailsPage({Key? key, required this.activity,this.lodging,required this.transport,required this.type, required this.trip}) : super(key: key);

  final ActivityData? activity;
  final LodgingData? lodging;
  final TransportationData? transport;
  final Trip trip;
  final String type;



  @override
  Widget build(BuildContext context) {
    switch (type){
      case 'Activity':
        return ActivityDetails(activity: activity!,trip: trip,);
      case 'Lodging':
        return LodgingDetails(lodging:lodging!,trip: trip,);
      default:
        return TransportationDetails(transport:transport!,);
    }
  }

}
