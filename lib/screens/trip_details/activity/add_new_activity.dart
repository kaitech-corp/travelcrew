import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/date_time_retrieval.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/in_app_review.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/time_picker.dart';
import '../../add_trip/google_autocomplete.dart';

class AddNewActivity extends StatefulWidget {
  const AddNewActivity({Key? key, required this.trip}) : super(key: key);

  final Trip trip;

  @override
  AddNewActivityState createState() => AddNewActivityState();
}

class AddNewActivityState extends State<AddNewActivity> {
  final UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<Timestamp> startDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<TimeOfDay> startTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final ValueNotifier<TimeOfDay> endTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final TextEditingController controller = TextEditingController();

  String activityType = '';
  String comment = '';
  String link = '';
  String location = '';
  late File urlToImage;
  bool timePickerVisible = false;

  bool loading = false;

  @override
  void initState() {
    startDateTimestamp.value = widget.trip.startDateTimeStamp;
    endDateTimestamp.value = widget.trip.endDateTimeStamp;
    controller.clear();
    super.initState();
  }

  @override
  void dispose() {
    startTime.dispose();
    endTime.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Add Activity',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Builder(
                  builder: (BuildContext context) => Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: TextFormField(
                              onChanged: (String val) {
                                setState(() => activityType = val);
                              },
                              enableInteractiveSelection: true,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ReusableThemeColor()
                                          .colorOpposite(context)),
                                ),
                                labelText:
                                    'Snorkeling, Festival, Restaurant, etc',
                              ),
                              // ignore: missing_return
                              validator: (String? value) {
                                if (value?.isEmpty ?? false) {
                                  return 'Please enter a lodging type.';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: TextFormField(
                              onChanged: (String val) {
                                setState(() => link = val);
                              },
                              enableInteractiveSelection: true,
                              // maxLines: 2,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ReusableThemeColor()
                                          .colorOpposite(context)),
                                ),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: TextFormField(
                              onChanged: (String val) {
                                setState(() => comment = val);
                              },
                              enableInteractiveSelection: true,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ReusableThemeColor()
                                          .colorOpposite(context)),
                                ),
                                labelText: 'Description',
                              ),
                              maxLines: 5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: TextFormField(
                              controller: controller,
                              enableInteractiveSelection: true,
                              // maxLines: 2,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ReusableThemeColor()
                                          .colorOpposite(context)),
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
                                controller: controller,
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
                          CalendarWidget(
                            startDateTimeStamp: startDateTimestamp,
                            endDateTimeStamp: endDateTimestamp,
                            showBoth: true,
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
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30.0, horizontal: 30.0),
                                child: ButtonTheme(
                                  child: ElevatedButton(
                                    child: Text(
                                      'Start/End Time',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        timePickerVisible = true;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ]),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final String documentID = widget.trip.documentId;
                  final String message =
                      'A new activity has been added to ${widget.trip.tripName}';
                  final bool ispublic = widget.trip.ispublic;
                  startDateTimestamp.value = DateTimeRetrieval()
                      .createNewTimestamp(
                          startDateTimestamp.value, startTime.value);
                  endDateTimestamp.value = DateTimeRetrieval()
                      .createNewTimestamp(
                          startDateTimestamp.value, endTime.value);
                  final FormState form = _formKey.currentState!;
                  if (form.validate()) {
                    try {
                      const String action = 'Saving new activity';
                      CloudFunction().logEvent(action);
                      await DatabaseService().addNewActivityData(
                          ActivityData(
                              activityType: activityType,
                              comment: comment.trim(),
                              startDateTimestamp: startDateTimestamp.value,
                              endDateTimestamp: endDateTimestamp.value,
                              displayName: currentUserProfile.displayName,
                              endTime: endTime.value.toString(),
                              fieldID: '',
                              link: link,
                              location: controller.text,
                              startTime: startTime.value.toString(),
                              uid: userService.currentUserID,
                              voters: <String>[], dateTimestamp: Timestamp.now()),
                          documentID);
                    } on Exception catch (e) {
                      CloudFunction().logError(
                          'Error adding new activity:  $e');
                    }
                    try {
                      const String action =
                          'Send notifications for edited activity';
                      CloudFunction().logEvent(action);
                      for (final String f in widget.trip.accessUsers) {
                        if (f != currentUserProfile.uid) {
                          CloudFunction().addNewNotification(
                            message: message,
                            documentID: documentID,
                            type: 'Activity',
                            uidToUse: f,
                            ownerID: currentUserProfile.uid,
                            ispublic: ispublic,
                          );
                        }
                      }
                    } on Exception catch (e) {
                      CloudFunction().logError(
                          'Error sending notifications for new activity:  $e');
                    }

                    setState(() {
                      loading = false;
                    });
                    navigationService.pop();
                    DatabaseService()
                        .appReviewExists(TCFunctions().appReviewDocID())
                        .then((bool value) => <void>{
                              if (!value)
                                <void>{
                                  InAppReviewClass().requestReviewFunc(),
                                  CloudFunction().addReview(
                                      docID: TCFunctions().appReviewDocID()),
                                }
                            });
                  }
                },
                child: const Icon(Icons.add),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
          );
  }
}
