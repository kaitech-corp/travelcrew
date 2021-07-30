import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/apple_login_bloc/apple_login_bloc.dart';
import 'package:travelcrew/blocs/apple_login_bloc/apple_login_event.dart';
import 'package:travelcrew/blocs/apple_login_bloc/apple_login_state.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:travelcrew/blocs/authentication_bloc/authentication_event.dart';
import 'package:travelcrew/blocs/google_login_bloc/google_login_bloc.dart';
import 'package:travelcrew/blocs/google_login_bloc/google_login_event.dart';
import 'package:travelcrew/blocs/google_login_bloc/google_login_state.dart';
import 'package:travelcrew/blocs/login_bloc/login_bloc.dart';
import 'package:travelcrew/blocs/login_bloc/login_event.dart';
import 'package:travelcrew/blocs/login_bloc/login_state.dart';
import 'package:travelcrew/repositories/user_repository.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/gradient_button.dart';

class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;

  const LoginForm({Key key, UserRepository userRepository})
      : _userRepository = userRepository,
        super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginWithEmailAndPasswordButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }
  bool isAppleLoginButtonEnabled(AppleLoginState state) {
    return !state.isSubmitting;
  }
  bool isGoogleLoginButtonEnabled(GoogleLoginState state) {
    return !state.isSubmitting;
  }
  LoginBloc _loginBloc;
  AppleLoginBloc _appleLoginBloc;
  GoogleLoginBloc _googleLoginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _appleLoginBloc = BlocProvider.of<AppleLoginBloc>(context);
    _googleLoginBloc = BlocProvider.of<GoogleLoginBloc>(context);
    _emailController.addListener(_onEmailChange);
    _passwordController.addListener(_onPasswordChange);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners:[
        BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              listenerMethod(state, context);
            }),
        BlocListener<AppleLoginBloc, AppleLoginState>(
            listener: (context, state) {
              listenerMethod(state, context);
            }),
        BlocListener<GoogleLoginBloc, GoogleLoginState>(
            listener: (context, state) {
              listenerMethod(state, context);
            }),
    ],
      child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              child: Column(
                children: [
                  BlocBuilder<LoginBloc, LoginState>(
                    bloc: _loginBloc,
                      builder: (context, state) {
                        return Column(
                            children: <Widget>[
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.email),
                                  labelText: "Email",
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autovalidate: true,
                                autocorrect: false,
                                validator: (_) {
                                  return !state.isEmailValid ? 'Invalid Email' : null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.lock),
                                  labelText: "Password",
                                ),
                                obscureText: true,
                                autovalidate: true,
                                autocorrect: false,
                                validator: (_) {
                                  return !state.isPasswordValid ? 'Invalid Password' : null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GradientButton(
                                width: 150,
                                height: 45,
                                onPressed: () {
                                  if (isLoginWithEmailAndPasswordButtonEnabled(state)) {
                                    _onFormSubmitted();
                                  }
                                },
                                text: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GradientButton(
                                width: 150,
                                height: 45,
                                onPressed: () {
                                  navigationService.navigateTo(SignUpScreenRoute);
                                },
                                text: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              )]);
                      }),
                  BlocBuilder<AppleLoginBloc, AppleLoginState>(
                      builder: (context, state) {
                          if (UserRepository().appleSignInAvailable) {
                            return OutlinedButton(
                              onPressed: () {
                                if (isAppleLoginButtonEnabled(state)) {
                                  _onPressedAppleSignIn();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image(image: AssetImage(apple_logo), height: 25.0),
                                    Text(signInWithApple,
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),)
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                  ),
                    BlocBuilder<GoogleLoginBloc, GoogleLoginState>(
                        builder: (context, state){

                      return OutlinedButton(
                        onPressed: () {
                          if (isGoogleLoginButtonEnabled(state)) {
                            _onPressedGoogleSignIn();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(image: AssetImage(google_logo), height: 25.0),
                              Text(signInWithGoogle,
                                style: TextStyle(
                                  color: Colors.black,
                                ),)
                            ],
                          ),
                        ),
                      );
                    }),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          child: const Text('Forgot Password?',),
                          onPressed: (){
                            TravelCrewAlertDialogs().resetPasswordDialog(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void listenerMethod(dynamic state, BuildContext context) {
    if (state.isFailure) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Login Failure'),
                Icon(Icons.error),
              ],
            ),
            backgroundColor: Color(0xffffae88),
          ),
        );
    }

    if (state.isSubmitting) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Logging In...'),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              ],
            ),
            backgroundColor: Color(0xffffae88),
          ),
        );
    }

    if (state.isSuccess) {
      BlocProvider.of<AuthenticationBloc>(context).add(
        AuthenticationLoggedIn(),
      );
    }
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChange() {
    _loginBloc.add(LoginEmailChange(email: _emailController.text));
  }

  void _onPasswordChange() {
    _loginBloc.add(LoginPasswordChanged(password: _passwordController.text));
  }

  void _onFormSubmitted() {
    _loginBloc.add(LoginWithCredentialsPressed(
        email: _emailController.text, password: _passwordController.text));
  }

  void _onPressedAppleSignIn(){
    _appleLoginBloc.add(AppleLoginPressed());
  }

  void _onPressedGoogleSignIn(){
    _googleLoginBloc.add(GoogleLoginPressed());
  }
}