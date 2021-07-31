import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/add_trip/google_places.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/calendar_widget.dart';

GoogleData googleData;

class AddTripPage extends StatefulWidget {

  //When using google places this object will pass on the location.
  final String addedLocation;

  AddTripPage({Key key, this.addedLocation}) : super(key: key);


  @override
  _AddTripPageState createState() => _AddTripPageState();
}

final AnalyticsService _analyticsService = AnalyticsService();
final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();
final myController = TextEditingController();
final ValueNotifier<GoogleData> googleData2 = ValueNotifier(googleData);

class _AddTripPageState extends State<AddTripPage> {
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final ValueNotifier<String> startDate = ValueNotifier('');
  final ValueNotifier<String> endDate = ValueNotifier('');
  final ValueNotifier<Timestamp> startDateTimestamp = ValueNotifier(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp = ValueNotifier(Timestamp.now());


  @override
  void initState() {
    super.initState();
    myController.clear();
    if(widget.addedLocation != null){
      myController.text = widget.addedLocation;
    }
  }

  @override
  void dispose() {
    startDate.dispose();
    startDateTimestamp.dispose();
    endDate.dispose();
    endDateTimestamp.dispose();
    // myController.dispose();
    super.dispose();
  }


  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File _image;
  bool gotDataBool = false;


  String comment = '';
  String displayName = '';
  String documentId = '';
  String firstName = '';
  String lastName = '';
  bool ispublic = true;
  String tripName = '';
  String location = '';
  String ownerID = '';
  String travelType = '';
  File urlToImage;



  updateGoogleDataValueNotifier() {
    googleData2.value = new GoogleData();
  }

  Future getImageAddTrip() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);


    setState(() {
      _image = File(image.path);
      urlToImage = File(_image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric( horizontal: 16.0),
        child: Builder(
            builder: (context) => Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                          enableInteractiveSelection: true,
                          textCapitalization: TextCapitalization.words,
                          initialValue: '',
                          decoration:
                          InputDecoration(
                              labelText: 'Trip Name',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                              )
                          ),
                          // ignore: missing_return
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a trip name';
                              // ignore: missing_return
                            }
                          },
                          onChanged: (val) =>
                          {
                            tripName = val,
                          }
                      ),
                      TextFormField(
                          enableInteractiveSelection: true,
                          textCapitalization: TextCapitalization.words,
                          initialValue: '',
                          autocorrect: true,
                          decoration:
                          InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                              )
                          ),
                          // ignore: missing_return
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a type.';
                              // ignore: missing_return
                            }
                          },
                          onChanged: (val) =>
                          {
                            travelType = val,
                          }
                      ),
                      TextFormField(
                        controller: myController,
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(labelText:'Location',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                            )
                        ),
                        onChanged: (value){
                          location = value;
                        },
                        // onSaved: (value){
                        //     myController.text = value;
                        // },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: GooglePlaces(homeScaffoldKey: homeScaffoldKey,searchScaffoldKey: searchScaffoldKey,),
                      ),
                      CalendarWidget(
                        startDate: startDate,
                        startDateTimeStamp: startDateTimestamp,
                        endDate: endDate,
                        endDateTimeStamp: endDateTimestamp,
                        context: context,
                        showBoth: true,
                      ),
                      SwitchListTile(
                          title: const Text('Public'),
                          value: ispublic,
                          onChanged: (bool val) =>
                          {
                            setState((){
                              ispublic = val;
                            }),

                          }
                      ),
                      (_image != null) ? Align(
                          alignment: Alignment.topRight,
                          child: IconButton(icon: Icon(Icons.clear),iconSize: 30, onPressed: (){ setState(() {
                            _image = null;
                            urlToImage = null;
                          });})): Container(),
                      Container(
                        child: _image == null
                            ? Text('No image selected.',style: Theme.of(context).textTheme.headline6,)
                            : Image.file(_image),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            getImageAddTrip();
                          },
//                              tooltip: 'Pick Image',
                          child: Icon(Icons.add_a_photo),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Text('Description',style: Theme.of(context).textTheme.subtitle1,),
                      ),
                      TextFormField(
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'Add a short description.',
                            hintStyle: Theme.of(context).textTheme.subtitle1
                        ),
                        style: Theme.of(context).textTheme.subtitle1,
                        onChanged: (val){
                          comment = val;
                        },
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              final form = _formKey.currentState;
                              form.save();
                              if (form.validate()) {
                                try {
                                  String action = 'Saving new Trip data';
                                  CloudFunction().logEvent(action);
                                  DatabaseService().addNewTripData(
                                      Trip(
                                        accessUsers: [userService.currentUserID],
                                        comment: comment,
                                        endDate: endDate.value,
                                        endDateTimeStamp:endDateTimestamp.value,
                                        startDateTimeStamp: startDateTimestamp.value,
                                        ispublic: ispublic,
                                        location: myController.text ?? '',
                                        startDate: startDate.value,
                                        travelType: travelType,
                                        tripGeoPoint: googleData2.value?.geoLocation ?? null,
                                        tripName: tripName,
                                      ),
                                      urlToImage,
                                      );
                                }  catch (e) {
                                  CloudFunction().logError('Error adding new Trip catch statement:  ${e.toString()}');
                                  _analyticsService.writeError('Error adding new Trip catch statement:  ${e.toString()}');
                                  TravelCrewAlertDialogs().newTripErrorDialog(context);
                                }
                                myController.text = '';
                                myController.clear();
                                form.reset();
                                setState(() {
                                  _image = null;
                                  ispublic =true;
                                });
                                TravelCrewAlertDialogs().addTripAlert(context);
                              }
                            },
                            child: const Text('Add Trip'),

                          )
                      ),
                    ]))));
  }
}