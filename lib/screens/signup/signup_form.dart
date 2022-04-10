import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/authentication_bloc/authentication_event.dart';
import '../../blocs/signup_bloc/signup_bloc.dart';
import '../../blocs/signup_bloc/signup_event.dart';
import '../../blocs/signup_bloc/signup_state.dart';
import '../../services/constants/constants.dart';
import '../../services/functions/tc_functions.dart';
import '../../services/widgets/gradient_button.dart';
import '../../size_config/size_config.dart';

class SignupForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<SignupForm> {
  File image;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final ValueNotifier<File> _urlToImage = ValueNotifier(File(''));

  final ImagePicker _picker = ImagePicker();

  bool imagePicked = false;
  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isButtonEnabled(SignupState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  SignupBloc _signupBloc;

  @override
  void initState() {
    super.initState();
    _signupBloc = BlocProvider.of<SignupBloc>(context);
    _emailController.addListener(_onEmailChange);
    _passwordController.addListener(_onPasswordChange);
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
    _passwordController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  getImage() async {
    var image =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 80);

    _cropImage(image.path, image);
    setState(() {
      imagePicked = true;
    });
  }

  _cropImage(imagePath, image) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imagePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );

    if (croppedImage != null) {
      _urlToImage.value = croppedImage;
    } else {
      _urlToImage.value = File(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Signup Failure'),
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
                children: const <Widget>[
                  Text('Registering...'),
                  CircularProgressIndicator(
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
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<SignupBloc, SignupState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    // autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isEmailValid ? 'Invalid Email' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isPasswordValid ? 'Invalid Password' : null;
                    },
                  ),
                  TextFormField(
                    controller: _displayNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Display Name',
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'First Name',
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Last Name',
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  imagePicked
                      ? Container(
                          height: (SizeConfig.screenWidth / 3) * 2.5,
                          // width: (SizeConfig.screenWidth/3)*1.9,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // color: Colors.orange,
                              image: DecorationImage(
                                  image: FileImage(_urlToImage.value),
                                  fit: BoxFit.cover)),
                        )
                      : const Text('Select a Profile Picture.',
                          style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () {
                      getImage();
                    },
                    child: const Icon(Icons.add_a_photo),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          agreementMessage(),
                          style: Theme.of(context).textTheme.subtitle1,
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
                      }
                    },
                    text: const Text(
                      'Signup',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.black,
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

  void _onEmailChange() {
    _signupBloc.add(SignupEmailChanged(email: _emailController.text));
  }

  void _onPasswordChange() {
    _signupBloc.add(SignupPasswordChanged(password: _passwordController.text));
  }

  void _onFirstNameChange() {
    _signupBloc
        .add(SignupFirstNameChanged(firstName: _firstNameController.text));
  }

  void _onLastNameChange() {
    _signupBloc.add(SignupLastNameChanged(lastName: _lastNameController.text));
  }

  void _onDisplayNameChange() {
    _signupBloc.add(
        SignupDisplayNameChanged(displayName: _displayNameController.text));
  }

  void _onImageChange() {
    _signupBloc.add(SignupImageChanged(urlToImage: _urlToImage.value));
  }

  void _onFormSubmitted() {
    _signupBloc.add(SignupSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _displayNameController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        urlToImage: _urlToImage.value));
  }
}
