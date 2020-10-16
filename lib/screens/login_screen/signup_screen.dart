import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
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
  String _urlToS = 'https://travelcrewkt.wordpress.com/terms-of-service/';
  String _urlToPrivacyPolicy = 'https://travelcrewkt.wordpress.com/travel-crew-privacy-policy/';

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(image.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sign Up!',style: Theme.of(context).textTheme.headline3,)),
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
                                style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                textCapitalization: TextCapitalization.words,
                                decoration:
                                InputDecoration(labelText: 'First Name',
                                labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                                // ignore: missing_return
                                onSaved: (val) =>
                                    setState(() => _user.firstName = val)),
                            TextFormField(
                              style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                              textCapitalization: TextCapitalization.words,
                              decoration:
                              InputDecoration(labelText: 'Last Name',
                              labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                              inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                              // ignore: missing_return

                              onSaved: (val) =>
                                  setState(() => _user.lastName = val),
                            ),
                            TextFormField(
                                style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                textCapitalization: TextCapitalization.words,
                                decoration:
                                InputDecoration(labelText: 'Display Name',
                                labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
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
                              style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                              decoration:
                              InputDecoration(labelText: 'Email',
                              labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                              inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
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
                                style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                decoration:
                                InputDecoration(labelText: 'Password',
                                labelStyle: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                // ignore: missing_return
                                validator: (value) {
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters.';
                                  }
                                },
                                obscureText: true,
                                onSaved: (val) =>
                                    setState(() => password = val)),
                            Padding(padding: EdgeInsets.only(top: 5),),
                            Container(
                              child: _image == null
                                  ? Text('Select a Profile Picture.',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold))
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
                                  Text("By pressing Signup you are agreeing to our Term's of Service, Privacy Policy.",style: Theme.of(context).textTheme.subtitle1,),
                                  FlatButton(
                                    child: Text('Terms of Service',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                    textColor: Colors.lightBlue,
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              WebViewScreen(_urlToS, key1),
                                          )
                                      );
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Privacy Policy',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                    textColor: Colors.lightBlue,
                                    onPressed: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            WebViewScreen(_urlToPrivacyPolicy, key1),
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
                                    child: Text('Sign Up!',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)))),
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