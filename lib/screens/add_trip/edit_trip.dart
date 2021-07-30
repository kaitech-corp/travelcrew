import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/add_trip/google_places.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/calendar_widget.dart';

import 'add_trip_page.dart';



class EditTripData extends StatefulWidget {
  final Trip tripDetails;
  EditTripData({this.tripDetails});
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

  File _image;
  File urlToImage;
  String documentID;
  bool ispublic = true;
  GeoPoint tripGeoPoint;

  @override
  void initState() {
    super.initState();
    controllerLocation.text = widget.tripDetails?.location ?? '';
    controllerTripName.text = widget.tripDetails?.tripName ?? '';
    controllerType.text = widget.tripDetails?.travelType ?? '';
    controllerComment.text = widget.tripDetails.comment;
    startDate.value = widget.tripDetails.startDate;
    endDate.value = widget.tripDetails.endDate;
    endDateTimestamp.value = widget.tripDetails.endDateTimeStamp;
    startDateTimestamp.value = widget.tripDetails.startDateTimeStamp;
    ispublic = widget.tripDetails.ispublic;
    documentID = widget.tripDetails.documentId;



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
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
      urlToImage = _image;
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        appBar: AppBar(
            title: Text('Edit Trip', style: Theme.of(context).textTheme.headline5,)),
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
                                  const InputDecoration(labelText: 'Trip Name or Location'),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a trip name';
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
                                  const InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)'),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a type.';
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
                                    decoration: const InputDecoration(labelText:'Location'),
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter a location.';
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
                                      const InputDecoration(labelText: 'Location'),
                                  ),
                                  ElevatedButton(
                                    child: const Text('Edit Location'),
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
                                  Text('Departure Date: ${widget.tripDetails.startDate}',style: TextStyle(fontSize: 15),),
                                  Text('Return Date: ${widget.tripDetails.endDate}',style: TextStyle(fontSize: 15)),
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
                                    ? const Text('No image selected.')
                                    : Image.file(_image),
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
                                child: Text('Description',style: Theme.of(context).textTheme.subtitle1,),
                              ),
                              TextFormField(
                                controller: controllerComment,
                                cursorColor: Colors.grey,
                                maxLines: 3,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: 'Add a short description.'),
                              ),
                            ]),
                    )))
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final form = _formKey.currentState;
          if (form.validate()) {
            // if(!dateChangeVisible){
            //   startDateTimeStamp = widget.tripDetails.startDateTimeStamp;
            //   endDateTimeStamp = widget.tripDetails.endDateTimeStamp;
            //   endDate = widget.tripDetails.endDate;
            //   startDate = widget.tripDetails.startDate;
            // } else
            // {
            //   startDate = DateFormat.yMMMd().format(_fromDateDepart);
            //   startDateTimeStamp = Timestamp.fromDate(_fromDateDepart);
            //   endDate = DateFormat.yMMMd().format(_fromDateReturn);
            //   endDateTimeStamp = Timestamp.fromDate(_fromDateReturn);
            // }
            if(locationChangeVisible){
              // location = myController.text;
              if(googleData2.value != null){
                tripGeoPoint = googleData2.value.geoLocation;
              }
            }
            navigationService.pop();
            try {
              String action = 'Saving edited Trip data';
              CloudFunction().logEvent(action);
              DatabaseService().editTripData(
                  controllerComment.text,
                  documentID,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Saving')));
    navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
  }
}


