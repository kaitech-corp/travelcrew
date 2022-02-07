import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/login_bloc/login_bloc.dart';
import '../../repositories_v1/user_repository.dart';
import '../../services/constants/constants.dart';
import '../../services/widgets/curved_widget.dart';
import '../../size_config/size_config.dart';
import 'login_form.dart';

/// Login screen
class LoginScreen extends StatelessWidget {

  final UserRepository _userRepository = UserRepository();

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
                        child: const AutoSizeText("Travel Crew",
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