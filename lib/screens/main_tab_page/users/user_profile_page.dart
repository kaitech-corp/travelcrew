import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';

class UserProfilePage extends StatelessWidget{
  UserProfile user;

  UserProfilePage({this.user});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(user.displayName, textScaleFactor: 2.25,style: TextStyle(color: Colors.blueAccent,),),
              Text('${user.firstname} ${user.lastname}', textScaleFactor: 1.9,style: TextStyle(color: Colors.blueAccent),),
              Container(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
                  child: user.urlToImage != null ? Image.network(user.urlToImage) : Text('No image selected.')
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}