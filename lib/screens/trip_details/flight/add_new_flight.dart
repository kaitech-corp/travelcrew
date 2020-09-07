import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';



class AddNewFlight extends StatefulWidget {
  @override
  _AddNewFlightState createState() => _AddNewFlightState();
}
class _AddNewFlightState extends State<AddNewFlight> {
  final _formKey = GlobalKey<FormState>();
  File _image;


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
  Timestamp startDateTimeStamp;
  Timestamp endDateTimeStamp;
  bool ispublic = true;
  String location = '';
  String ownerID = '';
  String startDate = '';
  String travelType = '';
  File urlToImage;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      urlToImage = _image;
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    ownerID = user.uid;
    List<String> accessUsers = [user.uid];
    displayName = user.displayName;

    return Scaffold(
        appBar: AppBar(title: Text('Create a Trip!')),
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
                                  decoration:
                                  InputDecoration(labelText: 'Trip Name or Location'),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a trip name';
                                    }
                                  },
                                  onChanged: (val) =>
                                  {
                                    location = val,
                                  }
                              ),
                              TextFormField(
                                  decoration:
                                  InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)'),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter a type.';
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
                                    Text(_labelTextDepart),
//                                SizedBox(height: 16),
                                    ButtonTheme(
                                      minWidth: 150,
                                      child: RaisedButton(
                                        child: Text(
                                          'Departure Date',
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
                                    Text(_labelTextReturn),
//                                SizedBox(height: 16),
                                    ButtonTheme(
                                      minWidth: 150,
                                      child: RaisedButton(
                                        child: Text(
                                          'Return Date',
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
                                  title: const Text('Private Trip'),
                                  value: false,
                                  onChanged: (bool val) =>
                                  {
                                    ispublic = val,
                                  }
                              ),
                              Container(
                                child: _image == null
                                    ? Text('No image selected.')
                                    : Image.file(_image),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  getImage();
                                },
//                              tooltip: 'Pick Image',
                                child: Icon(Icons.add_a_photo),
                              ),

                              Container(
                                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: Text('Description'),
                              ),
                              TextFormField(
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Add a short description.'),
                                onChanged: (val){
                                  comment = val;
                                },
                              ),
//

                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  child: RaisedButton(
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        if (form.validate()) {
                                          _showDialog(context);
//                                      print(_image.path);
//                                          print(displayName);
//                                      print(accessUsers);
//                                      print(endDate);
//                                      print(endDateTimeStamp);
//                                      print(ispublic);
//                                      print(location);
//                                      print(ownerID);
//                                      print(startDate);
//                                      print(travelType);
//                                      print(urlToImage);
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

