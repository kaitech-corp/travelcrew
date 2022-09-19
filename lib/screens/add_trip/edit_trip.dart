import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/trip_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/calendar_widget.dart';
import 'add_trip_page.dart';
import 'google_autocomplete.dart';


/// Edit trip page
class EditTripData extends StatefulWidget {
  const EditTripData({Key? key, required this.trip}) : super(key: key);
  final Trip trip;
  @override
  EditTripDataState createState() => EditTripDataState();
}
class EditTripDataState extends State<EditTripData> {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<String> startDate = ValueNotifier<String>('');
  final ValueNotifier<String> endDate = ValueNotifier<String>('');
  final ValueNotifier<Timestamp> startDateTimestamp = ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp = ValueNotifier<Timestamp>(Timestamp.now());

  final TextEditingController controllerLocation = TextEditingController();
  final TextEditingController controllerTripName = TextEditingController();
  final TextEditingController controllerType = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();


  bool dateChangeVisible = false;
  bool locationChangeVisible = false;

  File? _image;
  File? urlToImage;
  String? documentID;
  bool ispublic = true;
  GeoPoint? tripGeoPoint;

  @override
  void initState() {
    super.initState();
    controllerLocation.text = widget.trip.location;
    controllerTripName.text = widget.trip.tripName;
    controllerType.text = widget.trip.travelType;
    controllerComment.text = widget.trip.comment;
    startDate.value = widget.trip.startDate;
    endDate.value = widget.trip.endDate;
    endDateTimestamp.value = widget.trip.endDateTimeStamp;
    startDateTimestamp.value = widget.trip.startDateTimeStamp;
    ispublic = widget.trip.ispublic;
    documentID = widget.trip.documentId;



  }

  @override
  void dispose() {
    startDateTimestamp.dispose();
    endDateTimestamp.dispose();
    controllerLocation.dispose();
    controllerType.dispose();
    controllerTripName.dispose();
    controllerComment.dispose();
    googleData2.dispose();
    super.dispose();
  }


  Future<void> getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image!.path);
      urlToImage = _image;
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.editTripPageTitle, style: Theme.of(context).textTheme.headline5,)),
        body: SingleChildScrollView(
            padding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Builder(
                builder: (BuildContext context) => Form(
                    key: _formKey,
                    child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: controllerTripName,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: <LengthLimitingTextInputFormatter>[
                                LengthLimitingTextInputFormatter(75),
                              ],
                              decoration:
                              InputDecoration(labelText: AppLocalizations.of(context)!.addTripNameLabel),
                              // ignore: missing_return
                              validator: (String? value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!.addTripNameValidator;
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
                              decoration:
                              InputDecoration(labelText: AppLocalizations.of(context)!.addTripTypeLabel),
                              // ignore: missing_return
                              validator: (String? value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!.addTripTypeValidator;
                                }
                                return null;
                              },
                          ),
                          if (locationChangeVisible) Column(
                            children: <Widget>[
                              TextFormField(
                                controller: controllerLocation,
                                enableInteractiveSelection: true,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(labelText:AppLocalizations.of(context)!.addTripLocation),
                                // ignore: missing_return
                                validator: (String? value) {
                                  if (value?.isEmpty ?? true) {
                                    return AppLocalizations.of(context)!.addTripLocationValidator;
                                    // ignore: missing_return
                                  }
                                  return null;
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 5, bottom: 5),
                                child: GooglePlaces(homeScaffoldKey: homeScaffoldKey,searchScaffoldKey: searchScaffoldKey,controller: controllerLocation,),),
                            ],
                          ) else Column(
                            children: <Widget>[
                              TextFormField(
                                controller: controllerLocation,
                                  textCapitalization: TextCapitalization.words,
                                  enabled: false,
                                  decoration:
                                  InputDecoration(labelText: AppLocalizations.of(context)!.addTripLocation),
                              ),
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.editTripPageEditLocation),
                                onPressed: (){
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
                          if (dateChangeVisible) CalendarWidget(
                            startDate: startDate,
                            startDateTimeStamp: startDateTimestamp,
                            endDate: endDate,
                            endDateTimeStamp: endDateTimestamp,
                            context: context,
                            showBoth: true,
                          ) else Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text('Departure Date: ${widget.trip.startDate}',style: const TextStyle(fontSize: 15),),
                              Text('Return Date: ${widget.trip.endDate}',style: const TextStyle(fontSize: 15)),
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.editDates),
                                onPressed: (){
                                  setState(() {
                                    dateChangeVisible = true;
                                  });
                                },
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 16.0),
                            child: _image == null
                                ? Text(AppLocalizations.of(context)!.addTripImageMessage)
                                : Image.file(_image!),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              getImage();
                            },
//                              tooltip: 'Pick Image',
                            child: const Icon(Icons.add_a_photo),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Text(AppLocalizations.of(context)!.addTripDescriptionMessage,style: Theme.of(context).textTheme.subtitle1,),
                          ),
                          TextFormField(
                            controller: controllerComment,
                            cursorColor: Colors.grey,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: AppLocalizations.of(context)!.addTripAddDescriptionMessage),
                          ),
                        ]),
                ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final FormState? form = _formKey.currentState;
          if (form!.validate()) {
            if(locationChangeVisible){
              // location = myController.text;
              tripGeoPoint = googleData2.value.geoLocation;
            }
            navigationService.pop();
            try {
              const String action = saveEditedTripData;
              CloudFunction().logEvent(action);
              DatabaseService().editTripData(
                  controllerComment.text,
                  documentID!,
                  endDate.value,
                  endDateTimestamp.value,
                  ispublic,
                  controllerLocation.text,
                  startDate.value,
                  startDateTimestamp.value,
                  controllerType.text,
                  urlToImage,
                  controllerTripName.text,
                  tripGeoPoint);
            } on Exception catch (e) {
              CloudFunction().logError('Error in edit trip function: ${e.toString()}');
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(addTripSavingDataMessage())));
    navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
  }
}
