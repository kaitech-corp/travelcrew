import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:travelcrew/services/navigation/route_names.dart';

class CompleteProfile extends StatefulWidget {


  @override
  _CompleteProfileState createState() => _CompleteProfileState();
}
class _CompleteProfileState extends State {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _user = UserSignUp();
  File _image;
  final picker = ImagePicker();
  String error = '';

  Key get key => null;
  Key key1;
  Future getImage() async {
    var image = await picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    String email = _auth.currentUser.email;
    print(email);
    final user = Provider.of<User>(context);
    _user.email = user.email;
    return Scaffold(
        appBar: AppBar(title: Text('Welcome!',style: Theme.of(context).textTheme.headline5,)),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Builder(
                  builder: (context) => Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 15,bottom: 15),
                              child: Column(
                                children: [
                                  Text('Add a display name and profile picture!'
                                    ,style: Theme.of(context).textTheme.subtitle1,
                                    textAlign: TextAlign.center,),
                                  Text('Both are optional and can be changed later.'
                                    ,style: Theme.of(context).textTheme.subtitle1,
                                    textAlign: TextAlign.center,),
                                ],
                              ),
                            ),
                            Container(height: 1,color: Colors.grey,),

                            TextFormField(
                                decoration:
                                const InputDecoration(labelText: 'Display Name',),
                                // ignore: missing_return
                                onSaved: (val) =>
                                    setState(() => _user.displayName = val)),
                            const Padding(padding: EdgeInsets.only(bottom: 20)),

                            Container(
                              child: _image == null
                                  ? const Text('No image selected.')
                                  : Image.file(_image),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                getImage();
                              },
//                              tooltip: 'Pick Image',
                              child: const Icon(Icons.add_a_photo),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("By continuing you are agreeing to our Term's of Service, Privacy Policy.",
                                    style: Theme.of(context).textTheme.subtitle1,
                                    textAlign: TextAlign.center,),
                                  TextButton(
                                    child: Text('Terms of Service',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                    onPressed: (){
                                      navigationService.navigateTo(WebViewScreenRoute, arguments: WebViewScreen(url: urlToTerms, key:key1));
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Privacy Policy',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                    onPressed: (){
                                      navigationService.navigateTo(WebViewScreenRoute, arguments: WebViewScreen(url: urlToPrivacyPolicy, key:key1));
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 30.0, horizontal: 30.0),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      final form = _formKey.currentState;
                                      if (form.validate()) {
                                        form.save();
                                        _showDialog(context);
                                        if(_user.displayName.isEmpty){
                                          _user.displayName = 'user${user.uid.substring(user.uid.length - 5)}';
                                        }

                                        DatabaseService().updateUserData(_user.
                                        firstName, _user.lastName, email, user.uid);
                                        DatabaseService().updateUserPublicProfileData(_user.displayName, _user.firstName, _user.lastName, email, 0, 0, user.uid, _image);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Wrapper()),
                                        );
                                      }
                                    },
                                    child: const Text('I Agree'))),
                            const SizedBox(height: 10,),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Creating Account')));
  }
}