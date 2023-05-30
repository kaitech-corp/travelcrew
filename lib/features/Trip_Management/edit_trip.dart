import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/trip_model/trip_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/image_picker_cropper/image_picker_cropper.dart';
import '../../services/navigation/route_names.dart';
import '../../services/theme/text_styles.dart';
import '../../services/widgets/calendar_widget.dart';
import 'add_trip_form.dart';
import 'components/google_autocomplete.dart';
import 'logic/logic.dart';

/// Edit trip page
class EditTripData extends StatefulWidget {
  const EditTripData({Key? key, required this.trip}) : super(key: key);
  final Trip trip;
  @override
  EditTripDataState createState() => EditTripDataState();
}

class EditTripDataState extends State<EditTripData> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final ValueNotifier<String> startDate = ValueNotifier<String>('');
  final ValueNotifier<String> endDate = ValueNotifier<String>('');
  final ValueNotifier<DateTime> startDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime> endDateTimestamp =
      ValueNotifier<DateTime>(DateTime.now());

  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerTripName = TextEditingController();
  final TextEditingController controllerType = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  // final ValueNotifier<GoogleData> googleData =
  //     ValueNotifier<GoogleData>(GoogleData());
  final ValueNotifier<File> urlToImage = ValueNotifier<File>(File(''));

  bool dateChangeVisible = false;
  bool locationChangeVisible = false;

  bool imagePicked = false;
  String? documentID;
  bool ispublic = true;
  GeoPoint? tripGeoPoint;

  @override
  void initState() {
    super.initState();
    controllerLocation.text = widget.trip.location ?? '';
    controllerTripName.text = widget.trip.tripName;
    controllerType.text = widget.trip.travelType ?? '';
    controllerComment.text = widget.trip.comment ?? '';
    startDate.value = widget.trip.startDate ?? '';
    endDate.value = widget.trip.endDate ?? '';
    endDateTimestamp.value = widget.trip.endDateTimeStamp!;
    startDateTimestamp.value = widget.trip.startDateTimeStamp!;
    ispublic = widget.trip.ispublic;
    documentID = widget.trip.documentId;
    tripGeoPoint = widget.trip.tripGeoPoint;
    if (widget.trip.urlToImage?.isNotEmpty ?? false) {
      urlToImage.value = File(widget.trip.urlToImage!);
    }
  }

  @override
  void dispose() {
    startDateTimestamp.dispose();
    endDateTimestamp.dispose();
    controllerLocation.dispose();
    controllerType.dispose();
    controllerTripName.dispose();
    controllerComment.dispose();
    // googleData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.of(context)!.editTripPageTitle,
        style: headlineMedium(context),
      )),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
              builder: (BuildContext context) => Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      TextFormField(
                        controller: controllerTripName,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: <LengthLimitingTextInputFormatter>[
                          LengthLimitingTextInputFormatter(75),
                        ],
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.addTripNameLabel),
                        // ignore: missing_return
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!
                                .addTripNameValidator;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: controllerType,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: <LengthLimitingTextInputFormatter>[
                          LengthLimitingTextInputFormatter(30),
                        ],
                        decoration: InputDecoration(
                            labelText:
                                AppLocalizations.of(context)!.addTripTypeLabel),
                        // ignore: missing_return
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!
                                .addTripTypeValidator;
                          }
                          return null;
                        },
                      ),
                      if (locationChangeVisible)
                        Column(
                          children: <Widget>[
                            TextFormField(
                              controller: controllerLocation,
                              enableInteractiveSelection: true,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .addTripLocation),
                              // ignore: missing_return
                              validator: (String? value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!
                                      .addTripLocationValidator;
                                  // ignore: missing_return
                                }
                                return null;
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: GooglePlaces(
                                homeScaffoldKey: homeScaffoldKey,
                                searchScaffoldKey: searchScaffoldKey,
                                controller: controllerLocation,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: <Widget>[
                            TextFormField(
                              controller: controllerLocation,
                              textCapitalization: TextCapitalization.words,
                              enabled: false,
                              decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!
                                      .addTripLocation),
                            ),
                            ElevatedButton(
                              child: Text(AppLocalizations.of(context)!
                                  .editTripPageEditLocation),
                              onPressed: () {
                                setState(() {
                                  locationChangeVisible = true;
                                });
                              },
                            )
                          ],
                        ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      if (dateChangeVisible)
                        CalendarWidget(
                          startDate: startDate,
                          startDateTimeStamp: startDateTimestamp,
                          endDate: endDate,
                          endDateTimeStamp: endDateTimestamp,
                          context: context,
                          showBoth: true,
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'Departure Date: ${widget.trip.startDate}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text('Return Date: ${widget.trip.endDate}',
                                style: const TextStyle(fontSize: 15)),
                            ElevatedButton(
                              child:
                                  Text(AppLocalizations.of(context)!.editDates),
                              onPressed: () {
                                setState(() {
                                  dateChangeVisible = true;
                                });
                              },
                            )
                          ],
                        ),
                      Container(
                          child: imagePicked
                              ? Image.file(urlToImage.value)
                              : Text(
                                  AppLocalizations.of(context)!
                                      .editTripImageMessage,
                                  style: headlineSmall(context),
                                )),
                      ElevatedButton(
                        onPressed: () async {
                          urlToImage.value = await ImagePickerAndCropper()
                              .uploadImage(urlToImage);
                          setState(() {
                            imagePicked = true;
                          });
                        },
//                              tooltip: 'Pick Image',
                        child: const Icon(Icons.add_a_photo),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Text(
                          AppLocalizations.of(context)!
                              .addTripDescriptionMessage,
                          style: titleMedium(context),
                        ),
                      ),
                      TextFormField(
                        controller: controllerComment,
                        cursorColor: Colors.grey,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context)!
                                .addTripAddDescriptionMessage),
                      ),
                    ]),
                  ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final FormState? form = _formKey.currentState;
          if (form!.validate()) {
            if (locationChangeVisible) {
              // location = myController.text;
              // tripGeoPoint = googleData.value.geoLocation;
            }
            navigationService.pop();
            try {
              const String action = saveEditedTripData;
              CloudFunction().logEvent(action);
              editTripData(
                  controllerComment.text,
                  documentID!,
                  endDate.value,
                  endDateTimestamp.value,
                  ispublic,
                  controllerLocation.text,
                  startDate.value,
                  startDateTimestamp.value,
                  controllerType.text,
                  urlToImage.value,
                  controllerTripName.text,
                  tripGeoPoint);
            } on Exception catch (e) {
              CloudFunction().logError('Error in edit trip function: $e');
            }
            _showDialog(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDialog(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(addTripSavingDataMessage())));
    navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
  }
}
