import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/menu_screens/privacy_policy/privacy_page.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';

import 'package:travelcrew/services/auth.dart';

class SignUpScreen extends StatefulWidget {


  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State {

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _user = UserSignUp();
  File _image;
  final picker = ImagePicker();

  String email = '';
  String password = '';
  String error = '';

  Key get key => null;
  Key key1;
  String urlToS = 'https://travelcrewkt.wordpress.com/terms-of-service/';

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(image.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sign Up!')),
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
                                    setState(() => _user.firstName = val)),
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
                                  setState(() => _user.lastName = val),
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
                                InputDecoration(labelText: 'Password'),
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
                                  ? Text('Select a Profile Picture.')
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
                                  Text("By pressing Signup you are agreeing to our terms of service, privacy policy and Apple's EULA."),
                                  FlatButton(
                                    child: Text('Terms of Service'),
                                    textColor: Colors.lightBlue,
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              WebViewScreen(urlToS, key1),
                                          )
                                      );
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Privacy Policy'),
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
                                      dynamic result = await _auth.signUpWithEmailAndPassword(_user.email, password, _user.firstName, _user.lastName, _user.displayName, _image);
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