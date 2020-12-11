import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/profile_page/profile_widget.dart';
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
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Text('Profile',style: Theme.of(context).textTheme.headline3,),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: const Icon(Icons.edit),
      //       onPressed: (){
      //         Navigator.pushNamed(context, '/editProfilePage');
      //       },
      //     )
      //   ],
      //     ),
      body: Stack(
        children: [
          HangingImageTheme3(),
          StreamBuilder(
            builder: (context, userData){
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

