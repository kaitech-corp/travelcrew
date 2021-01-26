import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/auth/auth.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/size_config/size_config.dart';

class SignUpScreen extends StatefulWidget {


  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State {

  final AuthService _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _user = UserSignUp();
  File _image;
  final ImagePicker _picker = ImagePicker();

  String email = '';
  String password = '';
  String error = '';

  Key get key => null;
  Key key1;

  getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    _cropImage(image.path, image);
  }

  _cropImage(imagePath, image) async{
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imagePath, maxHeight: 1080, maxWidth: 1080,);

    if (croppedImage != null) {
      setState(() {
        _image = croppedImage;
      });
    } else {
      setState(() {
        _image = File(image.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Sign Up!',style: Theme.of(context).textTheme.headline3,)),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Builder(
                  builder: (context) => Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                                style: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                textCapitalization: TextCapitalization.words,
                                decoration:
                                const InputDecoration(labelText: 'First Name',
                                labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                                // ignore: missing_return
                                onSaved: (val) =>
                                    setState(() => _user.firstName = val)),
                            TextFormField(
                              style: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                              textCapitalization: TextCapitalization.words,
                              decoration:
                              const InputDecoration(labelText: 'Last Name',
                              labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                              inputFormatters: [FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))],
                              // ignore: missing_return

                              onSaved: (val) =>
                                  setState(() => _user.lastName = val),
                            ),
                            TextFormField(
                                style:const  TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                textCapitalization: TextCapitalization.words,
                                decoration:
                                const InputDecoration(labelText: 'Display Name',
                                labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
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
                              style: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                              const InputDecoration(labelText: 'Email',
                              labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
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
                                style: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                                decoration:
                                const InputDecoration(labelText: 'Password',
                                labelStyle: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
                                // ignore: missing_return
                                validator: (value) {
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters.';
                                  }
                                },
                                obscureText: true,
                                onSaved: (val) =>
                                    setState(() => password = val)),
                            const Padding(padding: EdgeInsets.only(top: 5),),
                            _image == null
                                ? const Text('Select a Profile Picture.',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold))
                                : Container(
                              height: (SizeConfig.screenWidth/3)*2.5,
                              // width: (SizeConfig.screenWidth/3)*1.9,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // color: Colors.orange,
                                  image: DecorationImage(
                                      image: FileImage(_image),
                                      fit: BoxFit.cover
                                  )
                              ),
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              ),
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
                                  Text(agreement,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
                                  FlatButton(
                                    child: const Text('Terms of Service',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold,fontSize: 18)),
                                    textColor: Colors.lightBlue,
                                    onPressed: (){
                                      navigationService.navigateTo(WebViewScreenRoute, arguments: WebViewScreen(url: urlToTerms, key:key1));
                                    },
                                  ),
                                  FlatButton(
                                    child: const Text('Privacy Policy',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 18)),
                                    textColor: Colors.lightBlue,
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
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    onPressed: () async {
                                      final form = _formKey.currentState;
                                    if (form.validate()) {
                                      form.save();
                                      _showDialog(context);
                                      dynamic result = await _auth.signUpWithEmailAndPassword(_user.email, password, _user.firstName, _user.lastName, _user.displayName, _image);
                                      if (result == null){
                                        setState(() => error = 'Sign in credentials are not valid!');
                                      }
                                      navigationService.navigateTo(WrapperRoute);
                                    }
                                    },
                                    child: const Text('Sign Up!',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold, fontSize: 20)))),
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
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: const Text('Creating Account')));
  }
}