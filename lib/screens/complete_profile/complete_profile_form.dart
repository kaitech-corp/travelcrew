import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/authentication_bloc/authentication_event.dart';
import '../../blocs/complete_profile_bloc/complete_profile_bloc.dart';
import '../../blocs/complete_profile_bloc/complete_profile_event.dart';
import '../../blocs/complete_profile_bloc/complete_profile_state.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/tc_functions.dart';
import '../../services/image_picker_cropper/image_picker_cropper.dart';
import '../../services/navigation/route_names.dart';
import '../../services/theme/text_styles.dart';
import '../../services/widgets/gradient_button.dart';
import '../../size_config/size_config.dart';


/// Form for complete profile page
class CompleteProfileForm extends StatefulWidget {
  const CompleteProfileForm({Key? key}) : super(key: key);

  @override
  State<CompleteProfileForm> createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {

  File? image;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final ValueNotifier<File> _urlToImage = ValueNotifier<File>(File(''));

  final ImagePicker _picker = ImagePicker();

  bool imagePicked = false;

  late CompleteProfileBloc _completeProfileBloc;

  bool get isPopulated =>
      _firstNameController.text.isNotEmpty ||
      _lastNameController.text.isNotEmpty ||
      _displayNameController.text.isNotEmpty ||
      _urlToImage.value.path.isNotEmpty;

  bool isButtonEnabled(CompleteProfileState state) {
    return isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _completeProfileBloc = BlocProvider.of<CompleteProfileBloc>(context);
    _displayNameController.addListener(_onDisplayNameChange);
    _firstNameController.addListener(_onFirstNameChange);
    _lastNameController.addListener(_onLastNameChange);
    _urlToImage.addListener(_onImageChange);
  }

  @override
  void dispose() {
    _urlToImage.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    _cropImage(image!.path, image);
    setState(() {
      imagePicked = true;
    });
  }

  Future<void> _cropImage(String imagePath, XFile image) async {
    final CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imagePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );

    if (croppedImage != null) {
      _urlToImage.value = croppedImage as File;
    } else {
      _urlToImage.value = File(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompleteProfileBloc, CompleteProfileState>(
      listener: (BuildContext context, CompleteProfileState state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Intl.message('CompleteProfile Failure')),
                  const Icon(Icons.error),
                ],
              ),
              backgroundColor: const Color(0xffffae88),
            ),
          );
        }
        if (state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(Intl.message('Registering...')),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                ],
              ),
              backgroundColor: const Color(0xffffae88),
            ),
          );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(
            AuthenticationLoggedIn(),
          );
          // Navigator.pop(context);
          navigationService.navigateTo(LaunchIconBadgerRoute);
        }
      },
      child: BlocBuilder<CompleteProfileBloc, CompleteProfileState>(
        builder: (BuildContext context, CompleteProfileState state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _displayNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      labelText: Intl.message('Display Name'),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      labelText: Intl.message('First Name'),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      labelText: Intl.message('Last Name'),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
if (imagePicked)
                    Column(
                      children: <Widget>[
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                imagePicked = false;
                              });
                            },
                            child: const Icon(Icons.close),
                          ),
                        ),
                        Container(
                          height: (SizeConfig.screenWidth / 3) * 2.5,
                          // width: (SizeConfig.screenWidth/3)*1.9,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // color: Colors.orange,
                              image: DecorationImage(
                                  image: FileImage(_urlToImage.value),
                                  fit: BoxFit.cover)),
                        ),
                      ],
                    )
                  else
                    Text(AppLocalizations.of(context)!.select_photo,
                        style: const TextStyle(
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () async {
                      _urlToImage.value = await ImagePickerAndCropper()
                          .uploadImage(_urlToImage);
                    },
                    child: const Icon(Icons.add_a_photo),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          agreementMessage(),
                          style: titleMedium(context),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            TCFunctions().launchURL(urlToTerms);
                          },
                          child: const Text('Terms of Service',
                              style: TextStyle(
                                fontFamily: 'Cantata One',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                        ),
                        TextButton(
                          onPressed: () {
                            TCFunctions().launchURL(urlToPrivacyPolicy);
                          },
                          child: const Text('Privacy Policy',
                              style: TextStyle(
                                  fontFamily: 'Cantata One',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GradientButton(
                    width: 150,
                    height: 45,
                    onPressed: () {
                      if (isButtonEnabled(state)) {
                        _onFormSubmitted();
                      } else {
                        _onFormSubmittedEmpty();
                      }
                    },
                    text: Text(Intl.message
                      ('Continue'),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onFirstNameChange() {
    _completeProfileBloc.add(
        CompleteProfileFirstNameChanged(firstName: _firstNameController.text));
  }

  void _onLastNameChange() {
    _completeProfileBloc.add(
        CompleteProfileLastNameChanged(lastName: _lastNameController.text));
  }

  void _onDisplayNameChange() {
    _completeProfileBloc.add(CompleteProfileDisplayNameChanged(
        displayName: _displayNameController.text));
  }

  void _onImageChange() {
    _completeProfileBloc
        .add(CompleteProfileImageChanged(urlToImage: _urlToImage.value));
            if (_urlToImage.value.path.isNotEmpty) {
      setState(() {
        imagePicked = true;
      });
    }
  }

  void _onFormSubmitted() {
    _completeProfileBloc.add(CompleteProfileSubmitted(
        displayName: _displayNameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        urlToImage: _urlToImage.value));
  }

  void _onFormSubmittedEmpty() {
    _completeProfileBloc.add(CompleteProfileSubmitted(
        displayName: '',
        firstName: '',
        lastName: '',
        urlToImage: _urlToImage.value));
  }
}
