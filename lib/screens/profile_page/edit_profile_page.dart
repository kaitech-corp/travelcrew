import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';

import '../../loading.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State {



  final _formKey = GlobalKey<FormState>();
  final _user = UserSignUp();
  File _image;
  final ImagePicker _picker = ImagePicker();
  String error = '';

  Key get key => null;

  Future getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: StreamBuilder<UserProfile>(
            stream: DatabaseService().currentUserPublicProfile,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                UserProfile user = snapshot.data;
                return SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Builder(
                          builder: (context) => Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                        decoration:
                                        InputDecoration(labelText: 'First Name'),
                                        textCapitalization: TextCapitalization.words,
                                        inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                                        initialValue: user.firstName,
                                        // ignore: missing_return
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please first name.';
                                          }
                                        },
                                        onSaved: (val) =>
                                            setState(() => _user.firstName = val)),
                                    TextFormField(
                                      decoration:
                                      InputDecoration(labelText: 'Last Name'),
                                      textCapitalization: TextCapitalization.words,
                                      inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                                      initialValue: user.lastName,
                                      // ignore: missing_return
                                      validator: (value) {
                                        // ignore: missing_return
                                        if (value.isEmpty) {
                                          return 'Please enter last name';
                                        }
                                      },
                                      onSaved: (val) =>
                                          setState(() => _user.lastName = val),
                                    ),
                                    TextFormField(
                                        initialValue: user.displayName,
                                        decoration:
                                        InputDecoration(labelText: 'Display Name'),
                                        // ignore: missing_return
                                        validator: (value) {
                                          // ignore: missing_return, missing_return
                                          if (value.isEmpty) {
                                            return 'Please enter a display name.';
                                          }
                                        },
                                        onSaved: (val) =>
                                            setState(() => _user.displayName = val)),
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.0),
                                    ),
                                    user.urlToImage == null ? Container(
                                      child: _image == null
                                          ? Text('No image selected.')
                                          : Image.file(_image),
                                    ):
                                    Container(
                                      child: _image == null
                                          ? Image.network(user.urlToImage)
                                          : Image.file(_image),
                                    ),
                                    Container(
                                      width: 30,
                                      child: RaisedButton(
                                        shape: CircleBorder(
                                        ),
                                        onPressed: () {
                                          getImage();
                                        },
//                              tooltip: 'Pick Image',
                                        child: Icon(Icons.add_a_photo),
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 30.0, horizontal: 30.0),
                                        width: 30,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(),
                                            onPressed: () async {
                                              final form = _formKey.currentState;
                                              if (form.validate()) {
                                                form.save();

                                                DatabaseService(uid: user.uid).editPublicProfileData(_user.displayName, _user.firstName, _user.lastName, _image);
                                                Navigator.pop(context);
                                              }

                                            },
                                            child: Text('Save'))
                                    ),

                                    SizedBox(height: 10,),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(error,
                                          style: TextStyle(color: Colors.red, fontSize: 16.0),),
                                      ],
                                    )
                                  ])))),
                );
              } else {
                return Loading();
              }
            }
        ));
  }
}