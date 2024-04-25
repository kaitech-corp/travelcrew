import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/database.dart';

import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/time_picker.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../services/functions/cloud_functions/admin_functions.dart';
import '../../services/functions/cloud_functions/notification_functions.dart';
import '../../size_config/size_config.dart';
import '../Activities/components/form_card.dart';
import '../Trip_Management/components/google_autocomplete.dart';
import 'logic/logic.dart';

/// Add new lodging item
class AddNewLodging extends StatefulWidget {
  const AddNewLodging({super.key, required this.trip});
  final Trip trip;

  @override
  State<AddNewLodging> createState() => _AddNewLodgingState();
}

class _AddNewLodgingState extends State<AddNewLodging> {
  final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<TimeOfDay> startTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final ValueNotifier<TimeOfDay> endTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final ValueNotifier<DateTime> startDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> endDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());
  final TextEditingController controller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String displayName = '';
  String documentID = '';
  String lodgingType = '';
  String comment = '';
  String link = '';
  String uid = '';
  late bool ispublic;
  bool timePickerVisible = false;

  @override
  void initState() {
    endDateTimestamp.value = widget.trip.endDateTimeStamp!;
    startDateTimestamp.value = widget.trip.startDateTimeStamp!;
    displayName = 'currentUserProfile.displayName';
    documentID = widget.trip.documentId;
    uid = userService.currentUserID;
    ispublic = widget.trip.ispublic;
    super.initState();
  }

  @override
  void dispose() {
    endTime.dispose();
    startTime.dispose();
    controller.dispose();
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Lodging',
            style: headlineMedium(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Builder(
            builder: (BuildContext context) => Form(
              key: _formKey,
              child: Column(children: <Widget>[
                FormCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: buildTextFormField(
                          onChanged: (String val) {
                            setState(() => lodgingType = val);
                          },
                          labelText: 'Hotel, Airbnb, etc',
                          textCap: true,
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
                        child: buildTextFormField(
                          onChanged: (String val) {
                            setState(() => link = val);
                          },

                          labelText: 'Link',

                          // ignore: missing_return
                          validator: (String? value) {
                            if (value!.trim().isNotEmpty &&
                                !value.startsWith('https')) {
                              return 'Please enter a valid link including https.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: buildTextFormField(
                          onChanged: (String val) {
                            setState(() => comment = val);
                          },
                          labelText: 'Description',
                        ),
                      ),
                    ],
                  ),
                ),
                FormCard(
                  size: SizeConfig.screenHeight * .2,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
                            controller: controller,
                            enableInteractiveSelection: true,
                            decoration: formInputDecoration('Address')),
                      ),
                      Flexible(
                        child: Center(
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
          onPressed: () async {
            final FormState form = _formKey.currentState!;
            if (form.validate()) {
              final String message =
                  'A new lodging has been added to ${widget.trip.tripName}';
              // startDateTimestamp.value = DateTimeRetrieval().createNewTimestamp(
              //     startDateTimestamp.value, startTime.value);
              // endDateTimestamp.value = DateTimeRetrieval()
              //     .createNewTimestamp(startDateTimestamp.value, endTime.value);

              try {
                final String action = 'Saving new lodging for $documentID';
                AdminCloudFunction().logEvent(action);
                await addNewLodging(
                    documentID,
                    LodgingModel(
                      comment: comment.trim(),
                      displayName: displayName,
                      endTime: endTime.value.format(context),
                      endDateTimestamp: endDateTimestamp.value,
                      link: link,
                      location: controller.text,
                      lodgingType: lodgingType,
                      startTime: startTime.value.format(context),
                      startDateTimestamp: startDateTimestamp.value,
                      uid: uid,
                      voters: <String>[],
                      fieldID: '',
                    ));
              } on Exception catch (e) {
                AdminCloudFunction().logError('Error adding new Lodging:  $e');
              }
              try {
                final String action =
                    'Sending notifications for $documentID lodging';
                AdminCloudFunction().logEvent(action);
                for (final String f in widget.trip.accessUsers) {
                  if (f != userService.currentUserID) {
                    NotificationCloudFunction().addNewNotification(
                      message: message,
                      documentID: documentID,
                      type: 'Lodging',
                      uidToUse: f,
                      ownerID: 'currentUserProfile.uid',
                      ispublic: ispublic,
                    );
                  }
                }
              } on Exception catch (e) {
                AdminCloudFunction().logError(
                    'Error sending notifications for new lodging:  $e');
              }
              navigationService.pop();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                  'CheckIn/CheckOut',
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
}
