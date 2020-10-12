import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';

class UserProfilePage extends StatelessWidget{
  UserProfile user;
  var userService = locator<UserService>();
  double defaultSize = SizeConfig.defaultSize;

  UserProfilePage({this.user});

  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile',style: Theme.of(context).textTheme.headline3,),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              ClipPath(
                clipper: CustomShape(),
                child: Container(
                  height: defaultSize.toDouble() * 15.0, //150
                  // color: Color(0xAA2D3D49),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(spaceImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: defaultSize), //10
                height: defaultSize * 30, //140
                width: defaultSize * 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: defaultSize * 0.8, //8
                  ),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: user.urlToImage.isNotEmpty ? NetworkImage(user.urlToImage,) : AssetImage(profileImagePlaceholder)
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
              Center(
                child: Column(
                  children: [
                    Text(user.displayName, textScaleFactor: 2.25,style: TextStyle(color: Colors.blueAccent,),),
                    Text('${user.firstName} ${user.lastName}', textScaleFactor: 1.9,style: TextStyle(color: Colors.blueAccent),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}