import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/time_picker.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/cloud_functions/admin_functions.dart';
import '../../services/functions/cloud_functions/notification_functions.dart';
import '../../size_config/size_config.dart';
import 'components/form_card.dart';
import 'components/google_autocomplete.dart';
import 'logic/logic.dart';

class AddNewActivity extends StatefulWidget {
  const AddNewActivity({super.key, required this.trip});

  final Trip trip;

  @override
  AddNewActivityState createState() => AddNewActivityState();
}

final TextEditingController activityLocationController =
    TextEditingController();

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
    endDateTimestamp.value = widget.trip.startDateTimeStamp!;
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
    required String labelText,
    bool textCap = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: formInputDecoration(labelText),
      onChanged: onChanged,
      validator: validator,
      textCapitalization:
          textCap ? TextCapitalization.none : TextCapitalization.words,
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
              backgroundColor: Colors.grey[300],
              appBar: AppBar(
                title: Text(
                  'Add Activity',
                  style: titleLarge(context),
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
                          FormCard(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                buildTextFormField(
                                  textCap: true,
                                  labelText: 'Bowling, Festival, Date, etc',
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
                                buildTextFormField(
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
                                buildTextFormField(
                                  labelText: 'Description',
                                  onChanged: (String val) {
                                    setState(() => comment = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          FormCard(
                            size: SizeConfig.screenHeight * .2,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: activityLocationController,
                                  decoration: formInputDecoration('Address'),
                                ),
                                Flexible(
                                  child: Center(
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
                                ),
                              ],
                            ),
                          ),
                          FormCard(
                            size: SizeConfig.screenHeight * .2,
                            child: Column(children: _addDateAndTime(context)),
                          )
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

  List<Widget> _addDateAndTime(BuildContext context) {
    return <Widget>[
      CalendarWidget(
        startDateTimeStamp: startDateTimestamp,
        endDateTimeStamp: endDateTimestamp,
        showBoth: true,
      ),
      if (timePickerVisible)
        TimePickers(
          lodging: false,
          startTime: startTime,
          endTime: endTime,
        ),
      if (timePickerVisible)
        Flexible(
          child: Center(
            child: ButtonTheme(
              child: ElevatedButton(
                child: Text(
                  'Remove Time',
                  style: titleMedium(context),
                ),
                onPressed: () {
                  setState(() {
                    timePickerVisible = !timePickerVisible;
                  });
                  if (kDebugMode) {
                    print(startTime.value);
                  }
                },
              ),
            ),
          ),
        ),
      if (!timePickerVisible)
        Flexible(
          child: Center(
            child: ButtonTheme(
              child: ElevatedButton(
                child: Text(
                  'Add Time',
                  style: titleMedium(context),
                ),
                onPressed: () {
                  setState(() {
                    timePickerVisible = true;
                  });
                  if (kDebugMode) {
                    print(startTime.value);
                  }
                },
              ),
            ),
          ),
        ),
    ];
  }

  Future<void> _submit() async {
    final String documentID = widget.trip.documentId;
    if (kDebugMode) {
      print(widget.trip.documentId);
    }
    final String message =
        'A new activity has been added to ${widget.trip.tripName}';
    final bool ispublic = widget.trip.ispublic;
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      try {
        const String action = 'Saving new activity';
        AdminCloudFunction().logEvent(action);
        await addNewActivity(
            ActivityModel(
                activityType: activityType,
                comment: comment.trim(),
                startDateTimestamp: startDateTimestamp.value,
                endDateTimestamp: endDateTimestamp.value,
                displayName: currentUserProfile.userPublicProfile!.displayName,
                endTime: timePickerVisible ? endTime.value.format(context) : '',
                fieldID: '',
                link: link,
                location: activityLocationController.text,
                startTime:
                    timePickerVisible ? startTime.value.format(context) : '',
                uid: userService.currentUserID,
                voters: <String>[],
                dateTimestamp: DateTime.now()),
            documentID);
      } on Exception catch (e) {
        AdminCloudFunction().logError('Error adding new activity:  $e');
      }
      try {
        const String action = 'Send notifications for edited activity';
        AdminCloudFunction().logEvent(action);
        for (final String f in widget.trip.accessUsers) {
          if (f != userService.currentUserID) {
            NotificationCloudFunction().addNewNotification(
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
        AdminCloudFunction()
            .logError('Error sending notifications for new activity:  $e');
      }

      setState(() {
        loading = false;
      });
      navigationService.pop();
      // DatabaseService()
      //     .appReviewExists(TCFunctions().appReviewDocID())
      //     .then((bool value) => <void>{
      //           if (!value)
      //             <void>{
      //               // InAppReviewClass().requestReviewFunc(),
      //               FeedbackCloudFunction()
      //                   .addReview(docID: TCFunctions().appReviewDocID()),
      //             }
      //         });
    }
  }
}
