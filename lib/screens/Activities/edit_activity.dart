import 'package:flutter/material.dart';

import '../../../services/database.dart';

import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/time_picker.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/cloud_functions/admin_functions.dart';
import '../../services/functions/cloud_functions/notification_functions.dart';
import '../../size_config/size_config.dart';
import '../Trip_Management/components/google_autocomplete.dart';
import 'components/form_card.dart';
import 'logic/logic.dart';

class EditActivity extends StatefulWidget {
  const EditActivity({super.key, required this.activity, required this.trip});

  final ActivityModel activity;
  final Trip trip;

  @override
  State<EditActivity> createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
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
  late ValueNotifier<DateTime> startDateTimestamp;
  late ValueNotifier<DateTime> endDateTimestamp;

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
    startDateTimestamp = ValueNotifier<DateTime>(widget.activity.startDateTimestamp!);
    endDateTimestamp = ValueNotifier<DateTime>(widget.activity.endDateTimestamp!);
    controllerComment.text = widget.activity.comment;
    controllerLink.text = widget.activity.link;
    controllerLocation.text = widget.activity.location;
    controllerType.text = widget.activity.activityType;
    startTime.value =
        TimeOfDay.fromDateTime(widget.activity.startDateTimestamp!);
    endTime.value = TimeOfDay.fromDateTime(widget.activity.startDateTimestamp!);
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

  InputDecoration formInputDecoration(String labelText) {
    return InputDecoration(
     
      labelText: labelText,
    );
  }

  TextFormField buildTextFormField({
    required String labelText,
    Function(String)? onChanged,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      enableInteractiveSelection: true,
      decoration: formInputDecoration(labelText),
      onChanged: onChanged,
      validator: validator,
      textCapitalization: TextCapitalization.words,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text(
            'Edit Activity',
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
                          controller: controllerType,
                          labelText: 'snorkeling, festival, restaurant, etc',
                          validator: (String? value) {
                            if (value?.isEmpty ?? false) {
                              return 'Please enter an activity.';
                            }
                            return null;
                          },
                        ),
                        buildTextFormField(
                          controller: controllerLink,

                            labelText: 'Link',
                   
                          validator: (String? value) {
                            if ((value?.isNotEmpty ?? false) &&
                                !value!.startsWith('https')) {
                              return 'Please enter a valid link including https.';
                            }
                            return null;
                          },
                        ),
                        buildTextFormField(
                          controller: controllerComment,
           
                            labelText: 'Description',
                          ),
                 
                      ],
                    ),
                  ),
                  FormCard(
                    size: SizeConfig.screenHeight * .2,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: controllerLocation,
                          enableInteractiveSelection: true,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ReusableThemeColor()
                                      .colorOpposite(context)),
                            ),
                            labelText: 'Location (i.e. Address)',
                          ),
                        ),
                        Flexible(
                          child: Center(
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
                        ),
                      ],
                    ),
                  ),
                  FormCard(
                    size: SizeConfig.screenHeight * .2,
                    child: Column(children: _addDateAndTIme(context)),
                  )
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

  List<Widget> _addDateAndTIme(BuildContext context) {
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
                              },
                            ),
                          ),
                        ),
                      ),
                  ];
  }

  Future<void> _submit() async {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      final String message =
          'An activity has been modified within ${widget.trip.tripName}';
      try {
        const String action = 'Saving edited activity data';
        AdminCloudFunction().logEvent(action);
        editActivityModel(
          comment: controllerComment.text,
          displayName: currentUserProfile.userPublicProfile!.displayName,
          documentID: documentID,
          link: controllerLink.text,
          activityType: controllerType.text,
          fieldID: fieldID,
          location: controllerLocation.text,
          startDateTimestamp: startDateTimestamp.value,
          endDateTimestamp: endDateTimestamp.value,
          startTime: timePickerVisible ? startTime.value.format(context) : widget.activity.startTime,
          endTime: timePickerVisible ? endTime.value.format(context) : widget.activity.endTime,
        );
      } on Exception catch (e) {
        AdminCloudFunction().logError('Error saving edited activity data: $e');
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
              ispublic: widget.trip.ispublic,
            );
          }
        }
      } catch (e) {
        AdminCloudFunction()
            .logError('Error sending notifications for edited activities: $e');
      }
    }
    navigationService.pop();
  }
}
