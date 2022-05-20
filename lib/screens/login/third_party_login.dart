import 'package:flutter/material.dart';

import '../../blocs/login_bloc/login_bloc.dart';
import '../../blocs/login_bloc/login_event.dart';
import '../../blocs/login_bloc/login_state.dart';
import '../../repositories/user_repository.dart';
import '../../services/constants/constants.dart';

class ThirdPartyLogin extends StatelessWidget {

  final LoginBloc loginBloc;
  final LoginState state;

  const ThirdPartyLogin({Key key, this.loginBloc, this.state}) : super(key: key);

  bool isAppleLoginButtonEnabled(LoginState state) {
    return !state.isSubmitting;
  }

  bool isGoogleLoginButtonEnabled(LoginState state) {
    return !state.isSubmitting;
  }

  @override
  Widget build(BuildContext context) {
    return UserRepository().appleSignInAvailable ? Column(
      children: [
        IntrinsicWidth(
          child: Column(
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
                          signInWithGoogle2,
                          style: Theme.of(context).textTheme.subtitle1
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ):
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            signUpOrSignIn,style: Theme.of(context).textTheme.subtitle1,
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
      ],
    );
  }
  void _onPressedAppleSignIn() {
    loginBloc.add(LoginWithApplePressed());
  }

  void _onPressedGoogleSignIn() {
    loginBloc.add(LoginWithGooglePressed());
  }
}