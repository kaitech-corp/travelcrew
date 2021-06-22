import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/authenticate/authenticate.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/screens/login_screen/complete_profile_page.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/widgets/launch_icon_badger.dart';
import 'package:travelcrew/size_config/size_config.dart';

// Checks whether user has authenticated and redirects to complete profile if user does not have a Public Profile in the database or to main page.
class Wrapper extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    SizeConfig().init(context);

    if (user == null) {
      return Authenticate();
    } else {
      // DatabaseService().saveDeviceToken();
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
       return FutureBuilder(
         builder: (context, data) {
           if (data.data == false) {
             return CompleteProfile();
           } else if (data.data == null){
             return Loading();
           }
           return LaunchIconBadger();
         },
         future: DatabaseService(uid: user.uid).checkUserHasProfile(),
       );
    }
  }
}