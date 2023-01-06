import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  bool get isEmailPopulated => _emailController.text.isNotEmpty;
  bool get isPasswordPopulated => _passwordController.text.isNotEmpty;

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
    return BlocListener<LoginBloc, LoginState>(
      listener: (BuildContext context, LoginState state) {
        listenerMethod(state, context);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: BlocBuilder<LoginBloc, LoginState>(
            bloc: _loginBloc,
            builder: (BuildContext context, LoginState state) {
              return Column(children: <Widget>[
                TextFormField(
                  key: const Key('email'),
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.email),
                    labelText: AppLocalizations.of(context)!.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) {
                    return state.isEmailValid ? null : AppLocalizations.of(context)!.invalid_email;
                  },
                ),
                TextFormField(
                  key: const Key('password'),
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: AppLocalizations.of(context)!.password,
                  ),
                  obscureText: true,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) {
                    return state.isPasswordValid ? null : AppLocalizations.of(context)!.invalid_password;
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                IntrinsicWidth(
                  child: Column(
                    children: <Widget>[
                      GradientButton(
                        width: 150,
                        height: 45,
                        onPressed: () {
                          if (isLoginWithEmailAndPasswordButtonEnabled(state)) {
                            _onFormSubmitted();
                          }
                        },
                        text: Text(
                          AppLocalizations.of(context)!.login,
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
                          padding: const EdgeInsets.fromLTRB(8,8,8.0,16),
                          child: TextButton(
                            child: Text(AppLocalizations.of(context)!.forgot_password),
                            onPressed: () {
                              TravelCrewAlertDialogs()
                                  .resetPasswordDialog(context);
                            },
                          ),
                        ),
                      ),
                      IntrinsicWidth(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                if (isGoogleLoginButtonEnabled(state)) {
                                  _onPressedGoogleSignIn();
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
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Image(
                                        image: AssetImage(google_logo),
                                        height: 25.0),
                                    Text(signInWithGoogle,
                                        style:
                                        Theme.of(context).textTheme.subtitle1)
                                  ],
                                ),
                              ),
                            ),
                            if (UserRepository().appleSignInAvailable)
                              const SizedBox(
                                height: 16,
                              ),
                            if (UserRepository().appleSignInAvailable)
                              SignInWithAppleButton(onPressed: (){
                                if (isAppleLoginButtonEnabled(state)) {
                                  _onPressedAppleSignIn();
                                }
                              }),


                          ],
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Text(AppLocalizations.of(context)!.dont_have_an_account),
                              TextButton(
                                child: Text(AppLocalizations.of(context)!.sign_up,
                                ),
                                onPressed: () {
                                  navigationService
                                      .navigateTo(SignUpScreenRoute);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  void listenerMethod(LoginState state, BuildContext context) {
    if (state.isFailure) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(AppLocalizations.of(context)!.login_failed),
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
                Text(AppLocalizations.of(context)!.logging_in),
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
    if (isEmailPopulated) {
      _loginBloc.add(LoginEmailChange(email: _emailController.text));
    }
  }

  void _onPasswordChange() {
    if (isPasswordPopulated) {
      _loginBloc.add(LoginPasswordChanged(password: _passwordController.text));
    }
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
