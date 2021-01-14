import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/google_places.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/appearance_widgets.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'dart:async';
import 'package:travelcrew/services/database.dart';

GoogleData googleData;

class AddTripPage extends StatefulWidget {

  //When using google places this object will pass on the location.
  final String addedLocation;
  
  // var currentUserProfile;

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
@override
  void initState() {
    super.initState();

    myController.clear();
    if(widget.addedLocation != null){
      myController.text = widget.addedLocation;
    }
  }



  final _formKey = GlobalKey<FormState>();
  File _image;
  final ImagePicker _picker = ImagePicker();
  bool gotDataBool = false;

  DateTime _fromDateDepart = DateTime.now();
  DateTime _fromDateReturn = DateTime.now();


  String get _labelTextDepart {
    startDate = DateFormat.yMMMd().format(_fromDateDepart);
    startDateTimeStamp = Timestamp.fromDate(_fromDateDepart);
    return DateFormat.yMMMd().format(_fromDateDepart);
  }
  String get _labelTextReturn {
    endDate = DateFormat.yMMMd().format(_fromDateReturn);
    endDateTimeStamp = Timestamp.fromDate(_fromDateReturn);
    return DateFormat.yMMMd().format(_fromDateReturn);
  }

  Future<void> _showDatePickerDepart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDateDepart,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDateDepart) {
      setState(() {
        _fromDateDepart = picked;
        _fromDateReturn = picked;

      });
    }
  }
  Future<void> _showDatePickerReturn() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDateReturn,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDateReturn) {
      setState(() {
        _fromDateReturn = picked;
      });
    }
  }


  String comment = '';
  String displayName = '';
  String documentId = '';
  String endDate = '';
  String firstName = '';
  String lastName = '';
  Timestamp startDateTimeStamp;
  Timestamp endDateTimeStamp;
  bool ispublic = true;
  String tripName = '';
  String location = '';
  String ownerID = '';
  String startDate = '';
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(_labelTextDepart,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
                                 ButtonTheme(
                                  minWidth: 150,
                                  child: RaisedButton(
                                    shape:  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Start Date',
                                    ),
                                    onPressed: () async {
                                      _showDatePickerDepart();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(_labelTextReturn,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
                                ButtonTheme(
                                  minWidth: 150,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'End Date',
                                    ),
                                    onPressed: () {
                                      _showDatePickerReturn();
                                    },
                                    // 
                                  ),
                                ),
                              ],
                            ),
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
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
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
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                  onPressed: () {
                                    location = myController.text;
                                    ownerID = currentUserProfile.uid;
                                    List<String> accessUsers = [currentUserProfile.uid];
                                    displayName = currentUserProfile.displayName;
                                    firstName = currentUserProfile.firstName;
                                    lastName = currentUserProfile.lastName;
                                    final form = _formKey.currentState;
                                    form.save();
                                    if (form.validate()) {
                                          try {
                                            String action = 'Saving new Trip data';
                                            CloudFunction().logEvent(action);
                                            DatabaseService().addNewTripData(
                                                accessUsers,
                                                comment,
                                                endDate,
                                                firstName,
                                                lastName,
                                                endDateTimeStamp,
                                                startDateTimeStamp,
                                                ispublic,
                                                location,
                                                startDate,
                                                travelType,
                                                urlToImage,
                                                googleData2.value?.geoLocation ?? null,
                                                tripName);
                                          }  catch (e) {
                                            CloudFunction().logError(e.toString());
                                            _analyticsService.writeError('Error adding new Trip:  ${e.toString()}');
                                            try {
                                              DatabaseService().addNewTripData(
                                                  accessUsers,
                                                  comment,
                                                  endDate,
                                                  firstName,
                                                  lastName,
                                                  endDateTimeStamp,
                                                  startDateTimeStamp,
                                                  ispublic,
                                                  '',
                                                  startDate,
                                                  travelType,
                                                  urlToImage,
                                                  null,
                                                  tripName);
                                            } on Exception catch (e) {
                                              CloudFunction().logError(e.toString());
                                            }
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


