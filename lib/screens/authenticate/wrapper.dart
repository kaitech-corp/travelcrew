import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/screens/authenticate/authenticate.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/screens/login_screen/complete_profile_page.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/launch_icon_badger.dart';
import 'package:travelcrew/size_config/size_config.dart';

class Wrapper extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);
    SizeConfig().init(context);

    if (user == null) {
      return Authenticate();
    } else {
      DatabaseService().saveDeviceToken();
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