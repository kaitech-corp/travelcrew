import 'dart:io';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../services/widgets/loading.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}
class _SignupScreenState extends State {



  final _formKey = GlobalKey<FormState>();
  final _user = UserPublicProfile();
  File _image;
  final ImagePicker _picker = ImagePicker();
  String error = '';
  String destination1 = '';
  String destination2 = '';
  String destination3 = '';

  Key get key => null;

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
        appBar: AppBar(title: const Text('Edit Profile')),
        body: StreamBuilder<UserPublicProfile>(
            stream: DatabaseService().currentUserPublicProfile,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                UserPublicProfile user = snapshot.data;
                return SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Builder(
                          builder: (context) => Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                        decoration:
                                        const InputDecoration(labelText: 'First Name'),
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
                                      const InputDecoration(labelText: 'Last Name'),
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
                                        decoration: const InputDecoration(labelText: 'Display Name'),
                                        textCapitalization: TextCapitalization.words,
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
                                        initialValue: user.hometown ?? '',
                                        decoration:
                                        const InputDecoration(labelText: 'Hometown'),
                                        // ignore: missing_return
                                        // validator: (value) {
                                        //   // ignore: missing_return, missing_retur
                                        //
                                        // },
                                        onSaved: (val) =>
                                            setState(() => _user.hometown = val.trim())),
                                    SizedBox(height: 20,),
                                    ExpandableTheme(
                                      data: ExpandableThemeData(
                                        iconSize: 20.0,
                                        iconColor: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.white,
                                      ),
                                      child: ExpandablePanel(
                                        header: Text('Social Media', style: Theme.of(context).textTheme.headline2,),
                                        // collapsed:
                                        expanded: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                                initialValue: user.instagramLink ?? '',
                                                decoration:
                                                const InputDecoration(labelText: 'Instagram'),
                                                // ignore: missing_return
                                                validator: (value) {
                                                  // ignore: missing_return, missing_return
                                                  if (value.isNotEmpty && !value.contains('https://www.instagram.com/')) {
                                                    return 'i.e. https://www.instagram.com/username';
                                                  }
                                                },
                                                onSaved: (val) =>
                                                    setState(() => _user.instagramLink = val)),
                                            TextFormField(
                                                initialValue: user.facebookLink ?? '',
                                                decoration:
                                                const InputDecoration(labelText: 'Facebook Link'),
                                                // ignore: missing_return
                                                validator: (value) {
                                                  // ignore: missing_return, missing_return
                                                  if (value.isNotEmpty && !value.contains('https://www.facebook.com/')) {
                                                    return 'i.e. https://www.facebook.com/username';
                                                  }
                                                },
                                                onSaved: (val) =>
                                                    setState(() => _user.facebookLink = val)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 25,),
                                    ExpandableTheme(
                                      data: ExpandableThemeData(
                                        iconSize: 20.0,
                                        iconColor: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.white,
                                      ),
                                      child: ExpandablePanel(
                                        header: Text('Destination Wish List', style: Theme.of(context).textTheme.headline2,),
                                        // collapsed:
                                        expanded: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                                initialValue: (user.topDestinations[0].isNotEmpty) ? user.topDestinations[0] : '',
                                                textCapitalization: TextCapitalization.words,
                                                decoration:
                                                const InputDecoration(labelText: 'Destination 1'),
                                                onSaved: (val) =>
                                                    setState(() => destination1 = val.trim())),
                                            TextFormField(
                                                initialValue: (user.topDestinations[1].isNotEmpty) ? user.topDestinations[1] : '',
                                                textCapitalization: TextCapitalization.words,
                                                decoration:
                                                const InputDecoration(labelText: 'Destination 2'),
                                                onSaved: (val) =>
                                                    setState(() => destination2 = val.trim())),
                                            TextFormField(
                                                initialValue: (user.topDestinations[2].isNotEmpty) ? user.topDestinations[2] : '',
                                                textCapitalization: TextCapitalization.words,
                                                decoration:
                                                const InputDecoration(labelText: 'Destination 3'),
                                                onSaved: (val) =>
                                                    setState(() => destination3 = val.trim())),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 50,),
                                    user.urlToImage == null ? Container(
                                      child: _image == null
                                          ? Text('No image selected.')
                                          : Image.file(_image),
                                    ):
                                    CircleAvatar(
                                      radius: SizeConfig.screenWidth/2.25,
                                      backgroundImage: _image == null
                                          ? NetworkImage(user.urlToImage)
                                          : FileImage(_image,),
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
                                        child: const Icon(Icons.add_a_photo),
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 30.0, horizontal: 30.0),
                                        width: 30,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)
                                            ),
                                            onPressed: () async {
                                              final form = _formKey.currentState;
                                              form.save();
                                              _user.topDestinations =[destination1,destination2,destination3];
                                              print(_user.hometown);
                                              if (form.validate()) {
                                                try {
                                                  String action = 'Editing Public Profile page from page';
                                                  CloudFunction().logEvent(action);
                                                  DatabaseService(uid: user.uid).editPublicProfileData(_user,_image);
                                                } on Exception catch (e) {
                                                  CloudFunction().logError('Editing Public Profile page from page: ${e.toString()}');
                                                  Navigator.pop(context);
                                                }
                                              }
                                              // await locator.reset().whenComplete(() => setupLocator());
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Save'))
                                    ),
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
                );
              } else {
                return Loading();
              }
            }
        ));
  }
}