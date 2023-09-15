import 'dart:io';

import 'package:flutter/material.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/in_app_review.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/time_picker.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/trip_model/trip_model.dart';
import 'components/google_autocomplete.dart';
import 'logic/logic.dart';

class AddNewActivity extends StatefulWidget {
  const AddNewActivity({super.key, required this.trip});

  final Trip trip;

  @override
  AddNewActivityState createState() => AddNewActivityState();
}
 final TextEditingController activityLocationController = TextEditingController();
class AddNewActivityState extends State<AddNewActivity> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<DateTime> startDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> endDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<TimeOfDay> startTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final ValueNotifier<TimeOfDay> endTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
 

  String activityType = '';
  String comment = '';
  String link = '';
  String location = '';
  late File urlToImage;
  bool timePickerVisible = false;

  bool loading = false;

  @override
  void initState() {
    startDateTimestamp.value = widget.trip.startDateTimeStamp!;
    endDateTimestamp.value = widget.trip.endDateTimeStamp!;
    activityLocationController.clear();
    super.initState();
  }

  @override
  void dispose() {
    startTime.dispose();
    endTime.dispose();
    activityLocationController.clear();
    super.dispose();
  }

  InputDecoration formInputDecoration(String labelText) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: ReusableThemeColor().colorOpposite(context)),
      ),
      labelText: labelText,
    );
  }

  TextFormField buildTextFormField({
    required TextInputType keyboardType,
    required String labelText,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: formInputDecoration(labelText),
      onChanged: onChanged,
      validator: validator,
      textCapitalization: TextCapitalization.words,
    );
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
                  style: headlineMedium(context),
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
                          buildTextFormField(
                            keyboardType: TextInputType.text,
                            labelText: 'Snorkeling, Festival, Restaurant, etc',
                            onChanged: (String val) {
                              setState(() => activityType = val);
                            },
                            validator: (String? value) {
                              if (value?.isEmpty ?? false) {
                                return 'Please enter a lodging type.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5),
                          buildTextFormField(
                            keyboardType: TextInputType.text,
                            labelText: 'Link',
                            onChanged: (String val) {
                              setState(() => link = val);
                            },
                            validator: (String? value) {
                              if ((value?.isNotEmpty ?? false) &&
                                  !value!.startsWith('https')) {
                                return 'Please enter a valid link with including https.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 5),
                          buildTextFormField(
                            keyboardType: TextInputType.multiline,
                            labelText: 'Description',
                            onChanged: (String val) {
                              setState(() => comment = val);
                            },
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: activityLocationController,
                            decoration:
                                formInputDecoration('Location (i.e. Address )'),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              child: GooglePlaces(
                                homeScaffoldKey: homeScaffoldKey,
                                searchScaffoldKey: searchScaffoldKey,
                                controller: activityLocationController,
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
                                      style: titleMedium(context),
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
                onPressed: _submit,
                child: const Icon(Icons.done),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
          );
  }

  Future<void> _submit() async {
    final String documentID = widget.trip.documentId;
    final String message =
        'A new activity has been added to ${widget.trip.tripName}';
    final bool ispublic = widget.trip.ispublic;
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      try {
        const String action = 'Saving new activity';
        CloudFunction().logEvent(action);
        await addNewActivity(
            ActivityModel(
                activityType: activityType,
                comment: comment.trim(),
                startDateTimestamp: startDateTimestamp.value,
                endDateTimestamp: endDateTimestamp.value,
                displayName: currentUserProfile.userPublicProfile!.displayName,
                endTime: endTime.value.format(context),
                fieldID: '',
                link: link,
                location: activityLocationController.text,
                startTime: startTime.value.format(context),
                uid: userService.currentUserID,
                voters: <String>[],
                dateTimestamp: DateTime.now()),
            documentID);
      } on Exception catch (e) {
        CloudFunction().logError('Error adding new activity:  $e');
      }
      try {
        const String action = 'Send notifications for edited activity';
        CloudFunction().logEvent(action);
        for (final String f in widget.trip.accessUsers) {
          if (f != userService.currentUserID) {
            CloudFunction().addNewNotification(
              message: message,
              documentID: documentID,
              type: 'Activity',
              uidToUse: f,
              ownerID: userService.currentUserID,
              ispublic: ispublic,
            );
          }
        }
      } on Exception catch (e) {
        CloudFunction()
            .logError('Error sending notifications for new activity:  $e');
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
                    CloudFunction()
                        .addReview(docID: TCFunctions().appReviewDocID()),
                  }
              });
    }
  }
}
