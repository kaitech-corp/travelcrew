import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/date_time_retrieval.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/time_picker.dart';
import '../../add_trip/google_autocomplete.dart';
import '../../authenticate/profile_stream.dart';

/// Add new lodging item
class AddNewLodging extends StatefulWidget {
  const AddNewLodging({Key? key, required this.trip}) : super(key: key);
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
  final ValueNotifier<Timestamp> startDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
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
    endDateTimestamp.value = widget.trip.endDateTimeStamp;
    startDateTimestamp.value = widget.trip.startDateTimeStamp;
    displayName = currentUserProfile.displayName;
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
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Builder(
            builder: (BuildContext context) => Form(
              key: _formKey,
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: TextFormField(
                    onChanged: (String val) {
                      setState(() => lodgingType = val);
                    },
                    enableInteractiveSelection: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
                      ),
                      labelText: 'Hotel, Airbnb, etc',
                    ),
                    textCapitalization: TextCapitalization.words,
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
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
                      ),
                      labelText: 'Link',
                    ),
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
                  child: TextFormField(
                    onChanged: (String val) {
                      setState(() => comment = val);
                    },
                    enableInteractiveSelection: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
                      ),
                      labelText: 'Description',
                    ),
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
                if (timePickerVisible)
                  TimePickers(
                    lodging: true,
                    startTime: startTime,
                    endTime: endTime,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 30.0),
                    child: ButtonTheme(
                      minWidth: 150,
                      child: ElevatedButton(
                        child: Text(
                          'CheckIn/Checkout',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onPressed: () {
                          setState(() {
                            timePickerVisible = true;
                          });
                        },
                      ),
                    ),
                  ),
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
              startDateTimestamp.value = DateTimeRetrieval().createNewTimestamp(
                  startDateTimestamp.value, startTime.value);
              endDateTimestamp.value = DateTimeRetrieval()
                  .createNewTimestamp(startDateTimestamp.value, endTime.value);

              try {
                final String action = 'Saving new lodging for $documentID';
                CloudFunction().logEvent(action);
                await DatabaseService().addNewLodgingData(
                    documentID,
                    LodgingData(
                      comment: comment.trim(),
                      displayName: displayName,
                      endTime: endTime.value.toString(),
                      endDateTimestamp: endDateTimestamp.value,
                      link: link,
                      location: controller.text,
                      lodgingType: lodgingType,
                      startTime: startTime.value.toString(),
                      startDateTimestamp: startDateTimestamp.value,
                      uid: uid,
                      voters: <String>[], fieldID: '',
                    ));
              } on Exception catch (e) {
                CloudFunction()
                    .logError('Error adding new Lodging:  ${e.toString()}');
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
                      ownerID: currentUserProfile.uid,
                      ispublic: ispublic,
                    );
                  }
                }
              } on Exception catch (e) {
                CloudFunction().logError(
                    'Error sending notifications for new lodging:  ${e.toString()}');
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
