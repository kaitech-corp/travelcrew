import 'package:flutter/material.dart';


import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/time_picker.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../Trip_Management/components/google_autocomplete.dart';
import 'logic/logic.dart';


/// Edit lodging data
class EditLodging extends StatefulWidget {
  const EditLodging({Key? key, required this.lodging, required this.trip})
      : super(key: key);

  final LodgingModel lodging;
  final Trip trip;

  @override
  State<EditLodging> createState() => _EditLodgingState();
}

class _EditLodgingState extends State<EditLodging> {

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
  final TextEditingController controller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? link;
  String? lodgingType;
  String? comment;
  late String documentID;
  late String fieldID;
  bool calendarVisible = false;
  bool timePickerVisible = false;

  @override
  void initState() {
    controller.text = widget.lodging.location;
    endDateTimestamp.value =
        widget.lodging.endDateTimestamp!;
    startDateTimestamp.value =
        widget.lodging.startDateTimestamp!;
    link = widget.lodging.link;
    lodgingType = widget.lodging.lodgingType;
    comment = widget.lodging.comment;
    startTime.value =
        TimeOfDay.fromDateTime(widget.lodging.startDateTimestamp!);
    endTime.value =
        TimeOfDay.fromDateTime(widget.lodging.startDateTimestamp!);
    documentID = widget.trip.documentId;
    fieldID = widget.lodging.fieldID;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    endDateTimestamp.dispose();
    startDateTimestamp.dispose();
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
            'Edit Lodging',
            style: headlineMedium(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (BuildContext context) => Form(
              key: _formKey,
              child: Column(children: <Widget>[
                TextFormField(
                  onSaved: (String? val) {
                    setState(() => lodgingType = val);
                  },
                  textCapitalization: TextCapitalization.sentences,
                  enableInteractiveSelection: true,
                  initialValue: lodgingType,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ReusableThemeColor().colorOpposite(context)),
                    ),
                    labelText: 'Hotel, Airbnb, etc',
                  ),
                  // ignore: missing_return
                  validator: (String? value) {
                    if (value?.isEmpty ?? false) {
                      return 'Please enter a lodging type.';
                    }
                    return null;
                  },
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                TextFormField(
                    onSaved: (String? val) {
                      setState(() => link = val);
                    },
                    enableInteractiveSelection: true,
                    initialValue: link,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                TextFormField(
                  onSaved: (String? val) {
                    setState(() => comment = val);
                  },
                  textCapitalization: TextCapitalization.sentences,
                  enableInteractiveSelection: true,
                  initialValue: comment,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ReusableThemeColor().colorOpposite(context)),
                    ),
                    labelText: 'Description',
                  ),
                  maxLines: 5,
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
                            color: ReusableThemeColor().colorOpposite(context)),
                      ),
                      labelText: 'Address',
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
                    style: headlineSmall(context),
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.black,
                ),
                if (calendarVisible)
                  CalendarWidget(
                    startDateTimeStamp: startDateTimestamp,
                    endDateTimeStamp: endDateTimestamp,
                    showBoth: true,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text(
                        'Edit Dates',
                        style: titleMedium(context),
                      ),
                      onPressed: () {
                        setState(() {
                          calendarVisible = true;
                        });
                      },
                    ),
                  ),
                if (timePickerVisible)
                  TimePickers(
                    lodging: true,
                    startTime: startTime,
                    endTime: endTime,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text(
                        'CheckIn/Checkout',
                        style: titleMedium(context),
                      ),
                      onPressed: () {
                        setState(() {
                          timePickerVisible = true;
                        });
                      },
                    ),
                  ),
              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final FormState form = _formKey.currentState!;
            // startDateTimestamp.value = DateTimeRetrieval()
            //     .createNewTimestamp(startDateTimestamp.value, startTime.value);
            // endDateTimestamp.value = DateTimeRetrieval()
            //     .createNewTimestamp(startDateTimestamp.value, endTime.value);
            if (form.validate()) {
              form.save();
              final String message =
                  'A lodging option has been modified within ${widget.trip.tripName}';

              try {
               editLodging(
                  comment: comment,
                  documentID: documentID,
                  endDateTimestamp: endDateTimestamp.value,
                  endTime: endTime.value.format(context),
                  fieldID: fieldID,
                  link: link,
                  location: controller.text,
                  lodgingType: lodgingType,
                  startDateTimestamp: startDateTimestamp.value,
                  startTime: startTime.value.format(context),
                );
              } on Exception catch (e) {
                CloudFunction()
                    .logError('Error adding new Trip:  $e');
              }
              try {
                final String action =
                    'Sending notifications for $documentID lodging';
                CloudFunction().logEvent(action);
                for (final String f in widget.trip.accessUsers) {
                  if (f != currentUserProfile.uid) {
                    CloudFunction().addNewNotification(
                      message: message,
                      documentID: documentID,
                      type: 'Lodging',
                      uidToUse: f,
                      ownerID: 'currentUserProfile.uid',
                    );
                  }
                }
              } catch (e) {
                CloudFunction().logError(
                    'Error sending notifications for edited lodging:  $e');
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
}
