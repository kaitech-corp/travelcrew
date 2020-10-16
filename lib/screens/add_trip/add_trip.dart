import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';



class AddTrip extends StatefulWidget {

  var currentUserProfile;

  @override
  _AddTripState createState() => _AddTripState();
}
class _AddTripState extends State<AddTrip> {
@override
  void initState() {
    super.initState();
    currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  }

  final _formKey = GlobalKey<FormState>();
  File _image;
  final ImagePicker _picker = ImagePicker();


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
  String location = '';
  String ownerID = '';
  String startDate = '';
  String travelType = '';
  File urlToImage;


  Future getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);


    setState(() {
      _image = File(image.path);
      urlToImage = File(_image.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    // profileService.currentUserProfile().then((value) => currentUserProfile = value);

    return Scaffold(
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
                                  InputDecoration(labelText: 'Trip Name or Location'),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a trip name';
                                    // ignore: missing_return
                                    }
                                  },
                                  onChanged: (val) =>
                                  {
                                    location = val,
                                  }
                              ),
                              TextFormField(
                                  enableInteractiveSelection: true,
                                  textCapitalization: TextCapitalization.words,
                                  decoration:
                                  InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)'),
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
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(_labelTextDepart,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
                                    ButtonTheme(
                                      minWidth: 150,
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
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
                                        child: Text(
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
                                  title: Text('Public'),
                                  value: ispublic,
                                  onChanged: (bool val) =>
                                  {
                                    setState((){
                                      ispublic = val;
                                    }),

                                  }
                              ),
                              Container(
                                child: _image == null
                                    ? Text('No image selected.')
                                    : Image.file(_image),
                              ),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onPressed: () {
                                  getImage();
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
                                decoration: InputDecoration(
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
                                        ownerID = currentUserProfile.uid;
                                        List<String> accessUsers = [currentUserProfile.uid];
                                        displayName = currentUserProfile.displayName;
                                        firstName = currentUserProfile.firstName;
                                        lastName = currentUserProfile.lastName;
                                        final form = _formKey.currentState;
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
                                                urlToImage);
                                      _showDialog(context);
                                      Navigator.pop(context);
                                        }
                                      },
                                      child: Text('Add Trip'))),
                            ]))))));
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Submitting form')));
  }
}

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

