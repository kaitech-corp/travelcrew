import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/locator.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/time_picker.dart';
import '../../add_trip/google_autocomplete.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({required this.activity, required this.trip});

  final ActivityData activity;
  final Trip trip;

  @override
  _EditActivityState createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController controllerType = TextEditingController();
  final TextEditingController controllerLink = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final ValueNotifier<TimeOfDay> startTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final ValueNotifier<TimeOfDay> endTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final ValueNotifier<Timestamp> startDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool calendarVisible = false;
  bool timePickerVisible = false;

  late String displayName;
  late String documentID;
  late String fieldID;

  @override
  void initState() {
    documentID = widget.trip.documentId;
    fieldID = widget.activity.fieldID!;
    startDateTimestamp.value =
        widget.activity.startDateTimestamp ?? widget.trip.startDateTimeStamp;
    endDateTimestamp.value =
        widget.activity.endDateTimestamp ?? widget.trip.startDateTimeStamp;
    controllerComment.text = widget.activity.comment ?? '';
    controllerLink.text = widget.activity.link ?? '';
    controllerLocation.text = widget.activity.location!;
    controllerType.text = widget.activity.activityType!;
    startTime.value =
        TimeOfDay.fromDateTime(widget.activity.startDateTimestamp!.toDate());
    endTime.value =
        TimeOfDay.fromDateTime(widget.activity.startDateTimestamp!.toDate());
    displayName = widget.activity.displayName!;

    super.initState();
  }

  @override
  void dispose() {
    controllerComment.dispose();
    controllerLink.dispose();
    controllerLocation.dispose();
    controllerType.dispose();
    endTime.dispose();
    startTime.dispose();
    startDateTimestamp.dispose();
    endDateTimestamp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Activity',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (BuildContext context) => Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  controller: controllerType,
                  enableInteractiveSelection: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'snorkeling, festival, restaurant, etc',
                  ),
                  // ignore: missing_return
                  validator: (String? value) {
                    if (value?.isEmpty ?? false) {
                      return 'Please enter an activity.';
                    } else {
                      return null;
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                TextFormField(
                  controller: controllerLink,
                  enableInteractiveSelection: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Link',
                  ),
                  // ignore: missing_return
                  validator: (String? value) {
                    if ((value?.isNotEmpty ?? false) &&
                        !value!.startsWith('https')) {
                      return 'Please enter a valid link with including https.';
                    }
                    return null;
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                TextFormField(
                  controller: controllerComment,
                  enableInteractiveSelection: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: TextFormField(
                    controller: controllerLocation,
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
                      ),
                      labelText: 'Location (i.e. Address )',
                    ),
                    // ignore: missing_return
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: GooglePlaces(
                      homeScaffoldKey: homeScaffoldKey,
                      searchScaffoldKey: searchScaffoldKey,
                      controller: controllerLocation,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                if (calendarVisible)
                  CalendarWidget(
                    startDateTimeStamp: startDateTimestamp,
                    endDateTimeStamp: endDateTimestamp,
                    showBoth: true,
                  )
                else
                  ElevatedButton(
                    child: Text(
                      'Edit Date',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    onPressed: () {
                      setState(() {
                        calendarVisible = true;
                      });
                    },
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                if (timePickerVisible)
                  TimePickers(
                    lodging: false,
                    startTime: startTime,
                    endTime: endTime,
                  )
                else
                  ElevatedButton(
                    child: Text(
                      'Start/End Time',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    onPressed: () {
                      setState(() {
                        timePickerVisible = true;
                      });
                    },
                  ),
              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final FormState form = _formKey.currentState!;
            if (form.validate()) {
              // form.save();
              final String message =
                  'An activity has been modified within ${widget.trip.tripName}';
              try {
                const String action = 'Saving edited activity data';
                CloudFunction().logEvent(action);
                DatabaseService().editActivityData(
                  comment: controllerComment.text,
                  displayName: displayName,
                  documentID: documentID,
                  link: controllerLink.text,
                  activityType: controllerType.text,
                  fieldID: fieldID,
                  location: controllerLocation.text,
                  startDateTimestamp: (startDateTimestamp.value == null)
                      ? widget.trip.startDateTimeStamp
                      : startDateTimestamp.value,
                  endDateTimestamp: (endDateTimestamp.value == null)
                      ? widget.trip.startDateTimeStamp
                      : endDateTimestamp.value,
                  startTime: startTime.value.toString(),
                  endTime: endTime.value.toString(),
                );
              } on Exception catch (e) {
                CloudFunction().logError(
                    'Error saving edited activity data:  ${e.toString()}');
              }

              try {
                const String action = 'Send notifications for edited activity';
                CloudFunction().logEvent(action);
                for (final String f in widget.trip.accessUsers) {
                  if (f != currentUserProfile.uid) {
                    CloudFunction().addNewNotification(
                      message: message,
                      documentID: documentID,
                      type: 'Activity',
                      uidToUse: f,
                      ownerID: currentUserProfile.uid,
                    );
                  }
                }
              } catch (e) {
                CloudFunction().logError(
                    'Error sending notifications for edited activities:  ${e.toString()}');
              }
            }
            navigationService.pop();
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
