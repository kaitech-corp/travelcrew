import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/complete_profile_bloc/complete_profile_bloc.dart';
import '../../repositories/user_repository.dart';
import '../../services/constants/constants.dart';
import '../../services/widgets/curved_widget.dart';
import '../../size_config/size_config.dart';
import 'complete_profile_form.dart';


/// Complete profile page after signup
class CompleteProfile extends StatelessWidget {

  const CompleteProfile({Key? key, UserRepository? userRepository})
      : _userRepository = userRepository,
        super(key: key);
  final UserRepository? _userRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Color(0xff6a515e),
        ),
      ),
      body: BlocProvider<CompleteProfileBloc>(
        create: (BuildContext context) => CompleteProfileBloc(userRepository: _userRepository),
        child: Container(
          height: SizeConfig.screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [canvasColor, Colors.blueAccent.shade100],
              // colors: [Colors.white, Colors.white.withOpacity(0.4)],
            ),
          ),
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                CurvedWidget(
                  child: Container(
                    padding: const EdgeInsets.only(top: 100, left: 50),
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.white.withOpacity(0.4)],
                      ),
                    ),
                    child: const Text(
                      'Complete Profile',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 230),
                  child: const CompleteProfileForm(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}