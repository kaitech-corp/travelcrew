import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/custom_objects.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/widgets/loading.dart';
import '../../size_config/size_config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserPublicProfile _user = UserPublicProfile();
  late File _image;
  final ImagePicker _picker = ImagePicker();
  String error = '';
  String destination1 = '';
  String destination2 = '';
  String destination3 = '';

  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  Future<void> _uploadImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    }
    _cropImage();
  }
  Future<void>  _cropImage() async {
    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: _pickedFile!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedImage != null) {
      _image = croppedImage as File;
    } else {
      _image = File(_user.urlToImage!);
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(Intl.message('Edit Profile'),
                style: Theme.of(context).textTheme.headline5)),
        body: StreamBuilder<UserPublicProfile>(
            stream: DatabaseService().currentUserPublicProfile,
            builder: (BuildContext context, AsyncSnapshot<UserPublicProfile> snapshot) {
              if (snapshot.hasData) {
                final UserPublicProfile user = snapshot.data as UserPublicProfile;
                return SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Builder(
                          builder: (BuildContext context) => Form(
                              key: _formKey,
                              child: Column(
                                  children: [
                                    if (user.urlToImage == null) Container(
                                            child: _image == null
                                                ? const Text('No image selected.')
                                                : Image.file(_image),
                                          ) else CircleAvatar(
                                            radius:
                                                SizeConfig.screenWidth / 2.25,
                                            child: FadeInImage.assetNetwork(placeholder: _image.path, image: user.urlToImage!),
                                          ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _uploadImage();
                                      },
//                              tooltip: 'Pick Image',
                                      child: const Icon(Icons.add_a_photo),
                                    ),
                                    TextFormField(
                                        decoration: const InputDecoration(
                                            labelText: 'First Name'),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r'\s\b|\b\s'))
                                        ],
                                        initialValue: user.firstName,
                                        // ignore: missing_return
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return 'Please add first name.';
                                          } else {
                                            return null;
                                          }
                                        },
                                        onSaved: (String? val) => setState(
                                            () => _user.firstName = val)),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                          labelText: 'Last Name'),
                                      textCapitalization:
                                          TextCapitalization.words,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'\s\b|\b\s'))
                                      ],
                                      initialValue: user.lastName,
                                      // ignore: missing_return
                                      validator: (String? value) {
                                        // ignore: missing_return
                                        if (value!.isEmpty) {
                                          return 'Please enter last name';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (String? val) =>
                                          setState(() => _user.lastName = val),
                                    ),
                                    TextFormField(
                                        initialValue: user.displayName,
                                        decoration: const InputDecoration(
                                            labelText: 'Display Name'),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        // ignore: missing_return
                                        validator: (String? value) {
                                          // ignore: missing_return,
                                          if (value!.isEmpty) {
                                            return 'Please enter a display name.';
                                          } else {
                                            return null;
                                          }
                                        },
                                        onSaved: (String? val) => setState(
                                            () => _user.displayName = val)),
                                    TextFormField(
                                        initialValue: user.hometown ?? '',
                                        decoration: const InputDecoration(
                                            labelText: 'Hometown'),
                                        onSaved: (String? val) => setState(
                                            () => _user.hometown = val!.trim())),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ExpandableTheme(
                                      data: const ExpandableThemeData(
                                        iconSize: 20.0,
                                        iconColor: Colors.black,
                                      ),
                                      child: ExpandablePanel(
                                        header: Text(
                                          'Social Media',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                        collapsed: Container(),
                                        expanded: Column(
                                          children: [
                                            TextFormField(
                                                initialValue:
                                                    user.instagramLink ?? '',
                                                decoration:
                                                    const InputDecoration(
                                                        labelText: 'Instagram'),
                                                // ignore: missing_return
                                                validator: (String? value) {
                                                  // ignore: missing_return,
                                                  if (value!.isNotEmpty &&
                                                      !value.contains(
                                                          'https://www.instagram.com/')) {
                                                    return 'i.e. https://www.instagram.com/username';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (String? val) => setState(() =>
                                                    _user.instagramLink = val)),
                                            TextFormField(
                                                initialValue: user
                                                        .facebookLink ??
                                                    '',
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Facebook Link'),
                                                // ignore: missing_return
                                                validator: (String? value) {
                                                  // ignore: missing_return,
                                                  if (value!.isNotEmpty &&
                                                      !value.contains(
                                                          'https://www.facebook.com/')) {
                                                    return 'i.e. https://www.facebook.com/username';
                                                  }
                                                  return null;
                                                },
                                                onSaved: (String? val) => setState(() =>
                                                    _user.facebookLink = val)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    ExpandableTheme(
                                      data: const ExpandableThemeData(
                                        iconSize: 20.0,
                                        iconColor: Colors.black,
                                      ),
                                      child: ExpandablePanel(
                                        header: Text(
                                          'Destination Wish List',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                        collapsed: Container(),
                                        expanded: Column(
                                          children: [
                                            TextFormField(
                                                initialValue: (user
                                                        .topDestinations![0]
                                                        .isNotEmpty)
                                                    ? user.topDestinations![0]
                                                    : '',
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      30),
                                                ],
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Destination 1'),
                                                onSaved: (String? val) => setState(() =>
                                                    destination1 = val!.trim())),
                                            TextFormField(
                                                initialValue: (user
                                                        .topDestinations![1]
                                                        .isNotEmpty)
                                                    ? user.topDestinations![1]
                                                    : '',
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      30),
                                                ],
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Destination 2'),
                                                onSaved: (String? val) => setState(() =>
                                                    destination2 = val!.trim())),
                                            TextFormField(
                                                initialValue: (user
                                                        .topDestinations![2]
                                                        .isNotEmpty)
                                                    ? user.topDestinations![2]
                                                    : '',
                                                inputFormatters: [
                                                  LengthLimitingTextInputFormatter(
                                                      30),
                                                ],
                                                textCapitalization:
                                                    TextCapitalization.words,
                                                decoration:
                                                    const InputDecoration(
                                                        labelText:
                                                            'Destination 3'),
                                                onSaved: (String? val) => setState(() =>
                                                    destination3 = val!.trim())),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          final FormState form = _formKey.currentState!;
                                          form.save();
                                          _user.topDestinations = [
                                            destination1,
                                            destination2,
                                            destination3
                                          ];
                                          if (form.validate()) {
                                            try {
                                              const String action =
                                                  'Editing Public Profile page from page';
                                              CloudFunction().logEvent(action);
                                              DatabaseService(uid: user.uid)
                                                  .editPublicProfileData(
                                                      _user, _image);
                                            } on Exception catch (e) {
                                              CloudFunction().logError(
                                                  'Editing Public Profile page from page: ${e.toString()}');
                                              Navigator.pop(context);
                                            }
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Save')),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          error,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 16.0),
                                        ),
                                      ],
                                    )
                                  ])))),
                );
              } else {
                return Loading();
              }
            }));
  }
}
