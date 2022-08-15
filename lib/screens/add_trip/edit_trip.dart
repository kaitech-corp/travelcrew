import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/trip_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/calendar_widget.dart';
import 'add_trip_page.dart';
import 'google_autocomplete.dart';
import 'google_places.dart';


/// Edit trip page
class EditTripData extends StatefulWidget {
  final Trip trip;
  EditTripData({required this.trip});
  @override
  _EditTripDataState createState() => _EditTripDataState();
}
class _EditTripDataState extends State<EditTripData> {


  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final ValueNotifier<String> startDate = ValueNotifier('');
  final ValueNotifier<String> endDate = ValueNotifier('');
  final ValueNotifier<Timestamp> startDateTimestamp = ValueNotifier(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp = ValueNotifier(Timestamp.now());

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
    controllerLocation.text = widget.trip.location ?? '';
    controllerTripName.text = widget.trip.tripName ?? '';
    controllerType.text = widget.trip.travelType ?? '';
    controllerComment.text = widget.trip.comment ?? '';
    startDate.value = widget.trip.startDate ?? '';
    endDate.value = widget.trip.endDate ?? '';
    endDateTimestamp.value = widget.trip.endDateTimeStamp ?? Timestamp.now();
    startDateTimestamp.value = widget.trip.startDateTimeStamp ?? Timestamp.now();
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


  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image!.path);
      urlToImage = _image;
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
            title: Text(editTripPageTitle(), style: Theme.of(context).textTheme.headline5,)),
        body: Container(
            child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Builder(
                    builder: (context) => Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: controllerTripName,
                                  textCapitalization: TextCapitalization.words,
                                  inputFormatters: [
                                    new LengthLimitingTextInputFormatter(75),
                                  ],
                                  decoration:
                                  InputDecoration(labelText: addTripNameLabel()),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return addTripNameValidator();
                                    }
                                  },
                              ),
                              TextFormField(
                                controller: controllerType,
                                  textCapitalization: TextCapitalization.words,
                                  inputFormatters: [
                                    new LengthLimitingTextInputFormatter(30),
                                  ],
                                  decoration:
                                  InputDecoration(labelText: addTripTypeLabel()),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return addTripTypeValidator();
                                    }
                                  },
                              ),
                              locationChangeVisible ?
                              Column(
                                children: [
                                  TextFormField(
                                    controller: controllerLocation,
                                    enableInteractiveSelection: true,
                                    textCapitalization: TextCapitalization.words,
                                    decoration: InputDecoration(labelText:addTripLocation()),
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return addTripLocationValidator();
                                        // ignore: missing_return
                                      }
                                    },
                                  ),
                                  Container(
                                    child: GooglePlaces(homeScaffoldKey: homeScaffoldKey,searchScaffoldKey: searchScaffoldKey,controller: controllerLocation,),
                                    padding: const EdgeInsets.only(top: 5, bottom: 5),),
                                ],
                              ):
                              Column(
                                children: [
                                  TextFormField(
                                    controller: controllerLocation,
                                      textCapitalization: TextCapitalization.words,
                                      enabled: false,
                                      decoration:
                                      InputDecoration(labelText: addTripLocation()),
                                  ),
                                  ElevatedButton(
                                    child: Text(editTripPageEditLocation()),
                                    onPressed: (){
                                      setState(() {
                                        locationChangeVisible = true;
                                      });
                                    },
                                  )
                                ],
                              ),
                              const Padding(
                                padding: const EdgeInsets.only(top: 10),
                              ),
                              dateChangeVisible ? CalendarWidget(
                                startDate: startDate,
                                startDateTimeStamp: startDateTimestamp,
                                endDate: endDate,
                                endDateTimeStamp: endDateTimestamp,
                                context: context,
                                showBoth: true,
                              ):
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text('Departure Date: ${widget.trip.startDate}',style: TextStyle(fontSize: 15),),
                                  Text('Return Date: ${widget.trip.endDate}',style: TextStyle(fontSize: 15)),
                                  ElevatedButton(
                                    child: const Text('Edit Dates'),
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
                                    ? Text(addTripImageMessage())
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
                                child: Text(addTripDescriptionMessage(),style: Theme.of(context).textTheme.subtitle1,),
                              ),
                              TextFormField(
                                controller: controllerComment,
                                cursorColor: Colors.grey,
                                maxLines: 3,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: addTripAddDescriptionMessage()),
                              ),
                            ]),
                    )))
        ),
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
              String action = saveEditedTripData;
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
  _showDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(addTripSavingDataMessage())));
    navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
  }
}


