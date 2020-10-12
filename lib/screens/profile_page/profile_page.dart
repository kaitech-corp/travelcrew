import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/profile_page/edit_profile_page.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../loading.dart';

class ProfilePage extends StatefulWidget{



  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  double defaultSize = SizeConfig.defaultSize;
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile',style: Theme.of(context).textTheme.headline3,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      EditProfilePage(),
                  )
              );
            },
          )
        ],
          ),
      body: StreamBuilder<UserProfile>(
        stream: DatabaseService().currentUserPublicProfile,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            UserProfile currentUserProfile = snapshot.data;
            return SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          image: currentUserProfile.urlToImage.isNotEmpty ? NetworkImage(currentUserProfile.urlToImage,) : AssetImage(profileImagePlaceholder)
                              
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(currentUserProfile.displayName, textScaleFactor: 2.25,style: TextStyle(color: Colors.black54,),),
                          Text('${currentUserProfile.firstName} ${currentUserProfile.lastName}', textScaleFactor: 1.9,style: TextStyle(color: Colors.black54),),
                          currentUserProfile.email.isEmpty ? Padding(padding: EdgeInsets.only(top: 2),) : Text('Email: ${currentUserProfile.email}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          );} else {
            return Loading();
          }
        }
      ),
    );
  }

}

