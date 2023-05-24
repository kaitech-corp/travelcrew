import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/locator.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/time_picker.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../Trip_Management/components/google_autocomplete.dart';
import 'logic/logic.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({Key? key, required this.activity, required this.trip})
      : super(key: key);

  final ActivityModel activity;
  final Trip trip;

  @override
  State<EditActivity> createState() => _EditActivityState();
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
  final ValueNotifier<DateTime> startDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> endDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool calendarVisible = false;
  bool timePickerVisible = false;

  late String displayName;
  late String documentID;
  late String fieldID;

  @override
  void initState() {
    super.initState();
    documentID = widget.trip.documentId;
    fieldID = widget.activity.fieldID;
    startDateTimestamp.value = widget.activity.startDateTimestamp!;
    endDateTimestamp.value = widget.activity.endDateTimestamp!;
    controllerComment.text = widget.activity.comment;
    controllerLink.text = widget.activity.link;
    controllerLocation.text = widget.activity.location;
    controllerType.text = widget.activity.activityType;
    startTime.value =
        TimeOfDay.fromDateTime(widget.activity.startDateTimestamp!);
    endTime.value =
        TimeOfDay.fromDateTime(widget.activity.startDateTimestamp!);
    displayName = widget.activity.displayName;
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
            style: headlineMedium(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (BuildContext context) => Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: controllerType,
                    enableInteractiveSelection: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'snorkeling, festival, restaurant, etc',
                    ),
                    validator: (String? value) {
                      if (value?.isEmpty ?? false) {
                        return 'Please enter an activity.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: controllerLink,
                    enableInteractiveSelection: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Link',
                    ),
                    validator: (String? value) {
                      if ((value?.isNotEmpty ?? false) &&
                          !value!.startsWith('https')) {
                        return 'Please enter a valid link including https.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: controllerComment,
                    enableInteractiveSelection: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Description',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: TextFormField(
                      controller: controllerLocation,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:
                                  ReusableThemeColor().colorOpposite(context)),
                        ),
                        labelText: 'Location (i.e. Address)',
                      ),
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
                      style: headlineSmall(context),
                    ),
                  ),
                  Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 5),
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
                        style: titleMedium(context),
                      ),
                      onPressed: () {
                        setState(() {
                          calendarVisible = true;
                        });
                      },
                    ),
                  const SizedBox(height: 5),
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
                        style: titleMedium(context),
                      ),
                      onPressed: () {
                        setState(() {
                          timePickerVisible = true;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _submit,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _submit() async {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      final String message =
          'An activity has been modified within ${widget.trip.tripName}';
      try {
        const String action = 'Saving edited activity data';
        CloudFunction().logEvent(action);
        editActivityModel(
          comment: controllerComment.text,
          displayName: displayName,
          documentID: documentID,
          link: controllerLink.text,
          activityType: controllerType.text,
          fieldID: fieldID,
          location: controllerLocation.text,
          startDateTimestamp: startDateTimestamp.value,
          endDateTimestamp: endDateTimestamp.value,
          startTime: startTime.value.format(context),
          endTime: endTime.value.format(context),
        );
      } on Exception catch (e) {
        CloudFunction().logError('Error saving edited activity data: $e');
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
        CloudFunction()
            .logError('Error sending notifications for edited activities: $e');
      }
    }
    navigationService.pop();
  }
}
