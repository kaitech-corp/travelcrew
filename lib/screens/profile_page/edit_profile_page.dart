import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/custom_objects.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/image_picker_cropper/image_picker_cropper.dart';
import '../../services/theme/text_styles.dart';
import '../../services/widgets/loading.dart';
import '../../size_config/size_config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier<File> _urlToImage = ValueNotifier<File>(File(''));
  late UserPublicProfile _user;
  bool imagePicked = false;

  String error = '';
  String destination1 = '';
  String destination2 = '';
  String destination3 = '';

  @override
  void initState() {
    super.initState();
    _user = UserPublicProfile.mock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Intl.message('Edit Profile'),
          style: headlineSmall(context),
        ),
      ),
      body: StreamBuilder<UserPublicProfile>(
        stream: DatabaseService().currentUserPublicProfile,
        builder:
            (BuildContext context, AsyncSnapshot<UserPublicProfile> snapshot) {
          if (snapshot.hasData) {
            final UserPublicProfile user = snapshot.data!;
            _user = _user.copyWith(
                displayName: user.displayName,
                email: user.email,
                firstName: user.firstName,
                hometown: user.hometown,
                lastName: user.lastName,
                blockedList: user.blockedList,
                followers: user.followers,
                following: user.following,
                topDestinations: user.topDestinations,
                tripsCreated: user.tripsCreated,
                tripsJoined: user.tripsJoined,
                uid: user.uid,
                urlToImage: user.urlToImage);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Builder(
                    builder: (BuildContext context) => Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          if (imagePicked)
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                ),
                                iconSize: 30,
                                onPressed: () {
                                  setState(() {
                                    imagePicked = false;
                                  });
                                },
                              ),
                            ),
                          if (imagePicked || _user.urlToImage == null)
                            Container(
                              child: _urlToImage.value == null
                                  ? const Text('No image selected.')
                                  : Image.file(_urlToImage.value),
                            )
                          else
                            CircleAvatar(
                              radius: SizeConfig.screenWidth / 2.25,
                              backgroundImage: NetworkImage(_user.urlToImage!),
                            ),
                          ElevatedButton(
                            onPressed: () async {
                              _urlToImage.value = await ImagePickerAndCropper()
                                  .uploadImage(_urlToImage);
                              if (_urlToImage.value.path.isNotEmpty) {
                                setState(() {
                                  imagePicked = true;
                                  _user = _user.copyWith(
                                      urlToImage: _urlToImage
                                          .value.path); // Update urlToImage
                                });
                              }
                            },
                            child: const Icon(Icons.add_a_photo),
                          ),
                          TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'First Name'),
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'\s\b|\b\s'))
                              ],
                              initialValue: user.firstName,
                              onSaved: (String? val) => {
                                    _user =
                                        _user = _user.copyWith(firstName: val),
                                  }),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Last Name'),
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: <FilteringTextInputFormatter>[
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'\s\b|\b\s'))
                            ],
                            initialValue: user.lastName,
                            onSaved: (String? val) =>
                                _user = _user.copyWith(lastName: val),
                          ),
                          TextFormField(
                            initialValue: user.displayName,
                            decoration: const InputDecoration(
                                labelText: 'Display Name'),
                            textCapitalization: TextCapitalization.words,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return 'Please enter a display name.';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (String? val) =>
                                _user = _user.copyWith(displayName: val!),
                          ),
                          TextFormField(
                            initialValue: user.hometown,
                            decoration:
                                const InputDecoration(labelText: 'Hometown'),
                            onSaved: (String? val) =>
                                _user = _user.copyWith(hometown: val!.trim()),
                          ),
                          const SizedBox(height: 25),
                          ExpandableTheme(
                            data: const ExpandableThemeData(
                              iconSize: 20.0,
                              iconColor: Colors.black,
                            ),
                            child: ExpandablePanel(
                              header: Text(
                                'Destination Wish List',
                                style: headlineSmall(context),
                              ),
                              collapsed: Container(),
                              expanded: Column(
                                children: <Widget>[
                                  _buildDestinationTextFormField(
                                      user.topDestinations?.isNotEmpty ?? false,
                                      0),
                                  _buildDestinationTextFormField(
                                      (user.topDestinations?.length ?? 0) > 1,
                                      1),
                                  _buildDestinationTextFormField(
                                      (user.topDestinations?.length ?? 0) > 2,
                                      2),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () async {
                              final FormState? form = _formKey.currentState;
                              print(form != null);
                              if (form != null && form.validate()) {
                                form.save();
                                _user = _user.copyWith(
                                    topDestinations: <String>[
                                      destination1,
                                      destination2,
                                      destination3
                                    ]);
                                try {
                                  DatabaseService(
                                          uid: userService.currentUserID)
                                      .editPublicProfileData(
                                          _user, _urlToImage.value);
                                  Navigator.pop(context);
                                } catch (e) {
                                  CloudFunction().logError(
                                      'Editing Public Profile page from page: $e');
                                  if (kDebugMode) {
                                    print('Error Editing Profile: $e');
                                  }
                                  Navigator.pop(context);
                                }
                              }
                              // Navigator.pop(context);
                            },
                            child: const Text('Save'),
                          ),
                          const SizedBox(height: 10),
                          if (error.isNotEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  error,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 16.0),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }

  TextFormField _buildDestinationTextFormField(bool condition, int index) {
    final String defaultValue =
        condition ? _user.topDestinations![index] as String : '';
    return TextFormField(
        initialValue: defaultValue,
        inputFormatters: <LengthLimitingTextInputFormatter>[
          LengthLimitingTextInputFormatter(30),
        ],
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: 'Destination ${index + 1}'),
        onSaved: (String? val) => setState(() {
              if (index == 0) destination1 = val!.trim();
              if (index == 1) destination2 = val!.trim();
              if (index == 2) destination3 = val!.trim();
            }));
  }
}
