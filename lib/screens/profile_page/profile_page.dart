import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/profile_page/profile_widget.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';

class ProfilePage extends StatefulWidget{

  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  double defaultSize = SizeConfig.defaultSize;
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          HangingImageTheme3(user: currentUserProfile,),
          StreamBuilder(
            builder: (context, userData){
              if(userData.hasError){
                CloudFunction().logError('Error streaming user data for Profile Page: ${userData.error.toString()}');
              }
              if(userData.hasData){
                UserPublicProfile user = userData.data;
                return ProfileWidget(user: user);
              } else {
                return ProfileWidget(user: currentUserProfile);
              }
            },
            stream: DatabaseService().currentUserPublicProfile,
          ),
        ],
      ),
    );
  }

}

