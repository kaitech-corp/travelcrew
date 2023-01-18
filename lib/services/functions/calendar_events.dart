import 'package:add_2_calendar/add_2_calendar.dart';

import '../../models/activity_model.dart';
import '../../models/custom_objects.dart';
import '../../models/lodging_model.dart';

Event createEvent(
    {ActivityData? activity,
      required DateTimeModel timeModel,
      LodgingData? lodging,
      required String type}){

  if(type == 'Activity') {
    final Event event = Event(
      title: activity!.activityType,
      description: activity.comment,
      location: activity.location,
      startDate: timeModel.startDate!,
      endDate: timeModel.endDate!,
    );
    return event;
  } else{
    final Event event = Event(
      title: lodging!.lodgingType,
      description: lodging.comment,
      location: lodging.location,
      startDate: timeModel.startDate!,
      endDate: timeModel.endDate!,
      // allDay: true,
    );
    return event;
  }
}
