import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/login_screen/privacy_page.dart';

import 'package:travelcrew/services/auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State {

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _user = UserSignUp();
  File _image;

  String email = '';
  String password = '';
  String error = '';

  Key get key => null;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Create a Trip!')),
        body: SingleChildScrollView(
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
                                // ignore: missing_return
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please first name.';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => _user.firstname = val)),
                            TextFormField(
                              decoration:
                              InputDecoration(labelText: 'Last Name'),
                              // ignore: missing_return
                              validator: (value) {
                                // ignore: missing_return
                                if (value.isEmpty) {
                                  return 'Please enter last name';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => _user.lastname = val),
                            ),
                            TextFormField(
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
                            TextFormField(
                              decoration:
                              InputDecoration(labelText: 'Email'),
                              // ignore: missing_return
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a email';
                                }
                              },
                              onSaved: (val) =>
                                  setState(() => _user.email = val),
                            ),
                            TextFormField(
                                decoration:
                                InputDecoration(labelText: 'Password)'),
                                // ignore: missing_return
                                validator: (value) {
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters.';
                                  }
                                },
                                obscureText: true,
                                onSaved: (val) =>
                                    setState(() => password = val)),
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
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text('By pressing Signup you are agreeing to our privacy policy.'),
                                  FlatButton(
                                    child: Text('View policy here!'),
                                    textColor: Colors.lightBlue,
                                    onPressed: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                      PrivacyPolicy(),
                                        )
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30.0, horizontal: 30.0),
                                child: RaisedButton(
                                    onPressed: () async {
                                      final form = _formKey.currentState;
                                    if (form.validate()) {
                                      form.save();
                                      _showDialog(context);
                                      dynamic result = await _auth.signUpWithEmailAndPassword(_user.email, password, _user.firstname, _user.lastname, _user.displayName);
                                      if (result == null){
                                        setState(() => error = 'Sign in credentials are not valid!');
                                      }
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Wrapper()),
                                      );
                                    }
                                    },
                                    child: Text('Sign Up!'))),
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
        ));
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Registering Account')));
  }
}