import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';



class HomeMaterial extends StatefulWidget {
  @override
  _HomeMaterialState createState() => _HomeMaterialState();
}
class _HomeMaterialState extends State<HomeMaterial> {
  final _formKey = GlobalKey<FormState>();
  PickedFile _image;
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
  String firstname = '';
  String lastname = '';
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
      _image = image;
      urlToImage = File(_image.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    ownerID = user.uid;
    List<String> accessUsers = [user.uid];
    displayName = user.displayName;
    firstname = user.firstName;
    lastname = user.lastName;




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
                                  enableInteractiveSelection: true,
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
                                    Text(_labelTextDepart),
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
                                    Text(_labelTextReturn),
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
                                  value: true,
                                  onChanged: (bool val) =>
                                  {
                                      ispublic = val,
                                  }
                              ),
                              Container(
                                child: _image == null
                                    ? Text('No image selected.')
                                    : Image.network(_image.path),
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
                                child: Text('Description'),
                              ),
                              TextFormField(
                                enableInteractiveSelection: true,
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
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        if (form.validate()) {
                                            DatabaseService().addNewTripData(
                                                accessUsers,
                                                comment,
                                                displayName,
                                                endDate,
                                                firstname,
                                                lastname,
                                                endDateTimeStamp,
                                                startDateTimeStamp,
                                                ispublic,
                                                location,
                                                ownerID,
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

