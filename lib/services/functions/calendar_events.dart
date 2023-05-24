import 'package:add_2_calendar/add_2_calendar.dart';

import '../../models/activity_model/activity_model.dart';
import '../../models/lodging_model/lodging_model.dart';



Event createEvent(
    {ActivityModel? activity,
      required DateTime startDate,
      required DateTime endDate,
      LodgingModel? lodging,
      required String type}){

  if(type == 'Activity') {
    final Event event = Event(
      title: activity!.activityType,
      description: activity.comment,
      location: activity.location,
      startDate: startDate,
      endDate: endDate!,
    );
    return event;
  } else{
    final Event event = Event(
      title: lodging!.lodgingType,
      description: lodging.comment,
      location: lodging.location,
      startDate: startDate,
      endDate: endDate,
      // allDay: true,
    );
    return event;
  }
}
