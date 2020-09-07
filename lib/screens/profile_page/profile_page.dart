import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/profile_page/edit_profile_page.dart';

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


    final user = Provider.of<UserProfile>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile'),
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
              user.email.isEmpty ? Padding(padding: EdgeInsets.only(top: 2),) : Text('Email: ${user.email}'),
              Container(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.elliptical(20, 20)),
                    child: user.urlToImage != null ? Image.network(user.urlToImage) : _image == null
                        ? Text('No image selected.')
                        : Image.file(_image),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  getImage();
                },
//                              tooltip: 'Pick Image',
                child: Icon(Icons.add_a_photo),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

}