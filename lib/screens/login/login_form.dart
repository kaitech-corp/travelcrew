import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/authentication_bloc/authentication_event.dart';
import '../../blocs/login_bloc/login_bloc.dart';
import '../../blocs/login_bloc/login_event.dart';
import '../../blocs/login_bloc/login_state.dart';
import '../../repositories/user_repository.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/gradient_button.dart';
import '../alerts/alert_dialogs.dart';

/// Form for login screen
class LoginForm extends StatefulWidget {
  final UserRepository? _userRepository;

  const LoginForm({Key? key, UserRepository? userRepository})
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

  bool isAppleLoginButtonEnabled(LoginState state) {
    return !state.isSubmitting;
  }

  bool isGoogleLoginButtonEnabled(LoginState state) {
    return !state.isSubmitting;
  }

  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChange);
    _passwordController.addListener(_onPasswordChange);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(listener: (context, state) {
          listenerMethod(state, context);
        }),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: BlocBuilder<LoginBloc, LoginState>(
            bloc: _loginBloc,
            builder: (context, state) {
              return Column(children: <Widget>[
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
                  // autovalidate: true,
                  autocorrect: false,
                  validator: (_) {
                    return !state.isPasswordValid
                        ? 'Invalid Password'
                        : null;
                  },
                ),
                const SizedBox(
                  height: 25,
                ),


                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GradientButton(
                        width: 150,
                        height: 45,
                        onPressed: () {
                          if (isLoginWithEmailAndPasswordButtonEnabled(
                              state)) {
                            _onFormSubmitted();
                          }
                        },
                        text: Text(
                          'Login',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        icon: const Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: Text(
                                'Forgot Password?'
                            ),
                            onPressed: () {
                              TravelCrewAlertDialogs().resetPasswordDialog(context);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          signUpOrSignIn(),style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (UserRepository().appleSignInAvailable) ElevatedButton(
                            onPressed: () {
                              if (isAppleLoginButtonEnabled(state)) {
                              _onPressedAppleSignIn();
                              }
                            },
                            style: ElevatedButtonTheme.of(context)
                                .style
                                ?.copyWith(
                                backgroundColor:
                                MaterialStateProperty.all(canvasColor)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Image(
                                      image: AssetImage(apple_logo),
                                      height: 25.0),
                                  Text(
                                    signInWithApple,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  )
                                ],
                              ),
                            ),
                          ),
                          if (UserRepository().appleSignInAvailable) SizedBox(width: 16,),
                          ElevatedButton(
                            onPressed: () {
                              if (isGoogleLoginButtonEnabled(state)) {
                                _onPressedGoogleSignIn();
                              }
                            },
                            style: ElevatedButtonTheme.of(context).style?.copyWith(
                                backgroundColor:
                                MaterialStateProperty.all(canvasColor)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Image(
                                      image: AssetImage(google_logo), height: 25.0),
                                  Text(
                                    signInWithGoogle,
                                    style: Theme.of(context).textTheme.subtitle1
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(Intl.message
                                  ("Don't have an account?")
                              ),
                              TextButton(
                                child: Text(Intl.message
                                  ("Sign Up"),
                                ),
                                onPressed: () {
                                  navigationService.navigateTo(SignUpScreenRoute);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,),

              ]);
            },),
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
                Text(Intl.message('Login Failure')),
                const Icon(Icons.error),
              ],
            ),
            backgroundColor: const Color(0xffffae88),
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
                Text(Intl.message('Logging In...')),
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

  void _onPressedAppleSignIn() {
    _loginBloc.add(LoginWithApplePressed());
  }

  void _onPressedGoogleSignIn() {
    _loginBloc.add(LoginWithGooglePressed());
  }
}
