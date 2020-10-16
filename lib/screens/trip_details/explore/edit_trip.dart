import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/services/database.dart';



class EditTripData extends StatefulWidget {
  final Trip tripDetails;
  EditTripData({this.tripDetails});
  @override
  _EditTripDataState createState() => _EditTripDataState();
}
class _EditTripDataState extends State<EditTripData> {
  final _formKey = GlobalKey<FormState>();
  File _image;
  final ImagePicker _picker = ImagePicker();
  String startDate;
  String endDate;
  Timestamp startDateTimeStamp;
  Timestamp endDateTimeStamp;

  DateTime _fromDateDepart = DateTime.now();
  DateTime _fromDateReturn = DateTime.now();

  bool dateChangeVisible = false;

  String get _labelTextDepart {

    return DateFormat.yMMMd().format(_fromDateDepart);
  }
  String get _labelTextReturn {

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
        if(_fromDateReturn.isBefore(_fromDateDepart)){
          _fromDateReturn = picked;
        }
        startDate = DateFormat.yMMMd().format(_fromDateDepart);
        startDateTimeStamp = Timestamp.fromDate(_fromDateDepart);
      });
    }
  }
  Future<void> _showDatePickerReturn() async {
    final picked = await showDatePicker(
      fieldLabelText: 'Return Date',
      context: context,
      initialDate: _fromDateReturn,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _fromDateReturn) {
      setState(() {
        _fromDateReturn = picked;
        endDate = DateFormat.yMMMd().format(_fromDateReturn);
        endDateTimeStamp = Timestamp.fromDate(_fromDateReturn);
      });
    }
  }


  File urlToImage;

  Future getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
      urlToImage = _image;
    });
  }


  @override
  Widget build(BuildContext context) {
    String documentID = widget.tripDetails.documentId;
    String comment = widget.tripDetails.comment;
    bool ispublic = widget.tripDetails.ispublic;
    String location = widget.tripDetails.location;
    String travelType = widget.tripDetails.travelType;

    print(widget.tripDetails.endDateTimeStamp);
    print(widget.tripDetails.startDateTimeStamp);




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
                                  textCapitalization: TextCapitalization.words,
                                  decoration:
                                  InputDecoration(labelText: 'Trip Name or Location'),
                                  initialValue: location,
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
                                  textCapitalization: TextCapitalization.words,
                                  decoration:
                                  InputDecoration(labelText: 'Type (i.e. work, vacation, wedding)'),
                                  initialValue: travelType,
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
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              dateChangeVisible ? Column(
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(_labelTextDepart,style: Theme.of(context).textTheme.subtitle1,),
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
                                        Text(_labelTextReturn,style: Theme.of(context).textTheme.subtitle1,),
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
                                ],
                              ):
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text('Departure Date: ${widget.tripDetails.startDate}',style: TextStyle(fontSize: 15),),
                                  Text('Return Date: ${widget.tripDetails.endDate}',style: TextStyle(fontSize: 15)),
                                  RaisedButton(
                                    color: Colors.blue[300],
                                    child: Text('Edit Dates'),
                                    onPressed: (){
                                      setState(() {
                                        dateChangeVisible = true;
                                      });
                                    },
                                  )
                                ],
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
                                child: Text('Description',style: Theme.of(context).textTheme.subtitle1,),
                              ),
                              TextFormField(
                                cursorColor: Colors.grey,
                                initialValue: comment,
                                maxLines: 3,
                                textCapitalization: TextCapitalization.words,
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
                                      onPressed: () {
                                        final form = _formKey.currentState;
                                        if (form.validate()) {
                                          if(!dateChangeVisible){
                                            startDateTimeStamp = widget.tripDetails.startDateTimeStamp;
                                            endDateTimeStamp = widget.tripDetails.endDateTimeStamp;
                                            endDate = widget.tripDetails.endDate;
                                            startDate = widget.tripDetails.startDate;
                                          } else
                                            {
                                              startDate = DateFormat.yMMMd().format(_fromDateDepart);
                                              startDateTimeStamp = Timestamp.fromDate(_fromDateDepart);
                                              endDate = DateFormat.yMMMd().format(_fromDateReturn);
                                              endDateTimeStamp = Timestamp.fromDate(_fromDateReturn);
                                            }
                                          DatabaseService().editTripData(comment, documentID, endDate, endDateTimeStamp, ispublic, location, startDate, startDateTimeStamp, travelType, urlToImage);
                                          _showDialog(context);
                                        }
                                      },
                                      child: Text('Save'))),
                            ]))))));
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Submitting form')));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          Wrapper(),
      ),
    );
  }
}

// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

