import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/add_trip/google_places.dart';
import 'dart:async';
import 'package:travelcrew/services/database.dart';




GoogleData googleData;


class AddTrip extends StatefulWidget {

  final String addedLocation;
  
  // var currentUserProfile;

  AddTrip({Key key, this.addedLocation}) : super(key: key);
  
  @override
  _AddTripState createState() => _AddTripState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();
final myController = TextEditingController();
final ValueNotifier<GoogleData> googleData2 = ValueNotifier(googleData);
class _AddTripState extends State<AddTrip> {
@override
  void initState() {
    super.initState();
    // currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

    myController.clear();
    if(widget.addedLocation != null){
      myController.text = widget.addedLocation;
    }
    // myController.addListener(addTripTextControllerFunction());
    // googleData2.addListener(updateGoogleDataValueNotifier);
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

    return Scaffold(
      key: homeScaffoldKey,
        appBar: AppBar(title: Text('Create a Trip!',style: Theme.of(context).textTheme.headline3,)),
        body: Container(
            child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Builder(
                    builder: (context) => Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                  enableInteractiveSelection: true,
                                  textCapitalization: TextCapitalization.words,
                                  decoration:
                                  const InputDecoration(labelText: 'Trip Name'),
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
                                  autocorrect: true,
                                  decoration:
                                  const InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)'),
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
                                  decoration: const InputDecoration(labelText:'Location'),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a location.';
                                      // ignore: missing_return
                                    }
                                  },
                                onSaved: (value){
                                    myController.text = value;
                                },
                              ),
                              Container(
                                  child: GooglePlaces(homeScaffoldKey: homeScaffoldKey,searchScaffoldKey: searchScaffoldKey,),
                              padding: EdgeInsets.only(top: 5, bottom: 5),),
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
                                    ? const Text('No image selected.')
                                    : Image.file(_image),
                              ),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onPressed: () {
                                  getImageAddTrip();
                                },
//                              tooltip: 'Pick Image',
                                child: Icon(Icons.add_a_photo),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: Text('Description',style: Theme.of(context).textTheme.subtitle1,),
                              ),
                              TextFormField(
                                enableInteractiveSelection: true,
                                textCapitalization: TextCapitalization.sentences,
                                cursorColor: Colors.grey,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Add a short description.'),
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

                                      _showDialog(context);
                                            myController.clear();
                                            // googleData2.dispose();
                                      Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Add Trip'))),
                            ]))))));
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: const Text('Submitting form')));
  }

// @override
// void dispose() {
//   // Clean up the controller when the widget is removed from the widget tree.
//   myController.dispose();
//   super.dispose();
// }
}


