import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/menu_screens/privacy_policy/privacy_page.dart';
import 'package:travelcrew/services/database.dart';

class CompleteProfile extends StatefulWidget {


  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}
class _CompleteProfileState extends State {


  final _formKey = GlobalKey<FormState>();
  final _user = UserSignUp();
  File _image;
  final picker = ImagePicker();

  String error = '';

  Key get key => null;

  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(image.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    _user.email = user.email;
    return Scaffold(
        appBar: AppBar(title: Text('Complete Profile')),
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
                                        DatabaseService().updateUserData(_user.
                                            firstName, _user.lastName, _user.email, user.uid);
                                        DatabaseService().updateUserPublicProfileData(_user.displayName, _user.firstName, _user.lastName, _user.email, 0, 0, user.uid, _image);
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
        .showSnackBar(SnackBar(content: Text('Saving Account')));
  }
}