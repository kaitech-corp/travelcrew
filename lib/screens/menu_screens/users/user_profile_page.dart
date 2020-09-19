import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';

class UserProfilePage extends StatelessWidget{
  UserProfile user;

  UserProfilePage({this.user});

  Widget build(BuildContext context) {
    final owner = Provider.of<UserProfile>(context);
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
              Text('${user.firstName} ${user.lastName}', textScaleFactor: 1.9,style: TextStyle(color: Colors.blueAccent),),
              Container(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/blank_profile_picture.png',
                    image: user.urlToImage,
                  )
//                    user.urlToImage != null ? Image.network(user.urlToImage) : Text('No image available.')
                ),
              ),
              IconButton(
                icon: Icon(Icons.flag,),
                onPressed: (){
                  _flagTripAlert(context, user.uid, owner.uid);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _flagTripAlert(BuildContext context, String uid, String owner) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Flag this user for objectionable content or behaviour?'),
          content: Text('Please use our feedback feature to provide specific details'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                CloudFunction().flagContent(owner, owner, user.urlToImage, '');
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}