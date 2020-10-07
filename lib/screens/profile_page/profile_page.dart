import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/profile_page/edit_profile_page.dart';
import 'package:travelcrew/services/database.dart';
import '../../loading.dart';

class ProfilePage extends StatefulWidget{


  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  
  @override
  Widget build(BuildContext context) {
    File urlToImage;
    File _image;
    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = image;
        urlToImage = _image;
      });
    }
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
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(15, 50, 0, 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(currentUserProfile.displayName, textScaleFactor: 2.25,style: TextStyle(color: Colors.blueAccent,),),
                  Text('${currentUserProfile.firstName} ${currentUserProfile.lastName}', textScaleFactor: 1.9,style: TextStyle(color: Colors.blueAccent),),
                  currentUserProfile.email.isEmpty ? Padding(padding: EdgeInsets.only(top: 2),) : Text('Email: ${currentUserProfile.email}'),
                  Container(
                    width: 250,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                        child: currentUserProfile.urlToImage != null ? Image.network(currentUserProfile.urlToImage, height: 250, width: 250, fit: BoxFit.cover,) : _image == null
                            ? Text('No image selected.')
                            : Image.file(_image),
                    ),
                  ),
                  Container(
                    width: 30,
                    child: RaisedButton(
                      shape: CircleBorder(
                      ),
                      onPressed: () {
                        getImage();
                      },
//                              tooltip: 'Pick Image',
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
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