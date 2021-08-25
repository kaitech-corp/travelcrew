import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/apple_login_bloc/apple_login_bloc.dart';
import 'package:travelcrew/blocs/google_login_bloc/google_login_bloc.dart';
import 'package:travelcrew/blocs/login_bloc/login_bloc.dart';
import 'package:travelcrew/repositories/user_repository.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/widgets/curved_widget.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'login_form.dart';


class LoginScreen extends StatelessWidget {

  final UserRepository _userRepository = UserRepository();

  // const LoginScreen({Key key, UserRepository userRepository})
  //     // : _userRepository = userRepository,
  //       :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body:
      MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(userRepository: _userRepository),),
          BlocProvider<AppleLoginBloc>(
            create: (context) => AppleLoginBloc(userRepository: _userRepository),),
          BlocProvider<GoogleLoginBloc>(
            create: (context) => GoogleLoginBloc(userRepository: _userRepository),)
        ],
        child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [canvasColor, Colors.blueAccent.shade100],
                )),
            child: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  CurvedWidget(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.only(top: SizeConfig.blockSizeHorizontal*10),
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.white.withOpacity(0.4)],
                          ),
                        ),
                        child: AutoSizeText("Travel Crew",
                          style: TextStyle(fontFamily:'RockSalt',
                              fontSize: 44,
                              color: Colors.blue),
                          maxLines: 2,
                          textAlign: TextAlign.center,),
                        ),
                    ),
                    ),
                  Container(
                    margin: const EdgeInsets.only(top: 230),
                    child: LoginForm(userRepository: _userRepository,),
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }
}