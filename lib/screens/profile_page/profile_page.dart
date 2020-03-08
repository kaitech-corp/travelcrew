import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';

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
          ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(0, 50, 0, 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(user.displayName, textScaleFactor: 2.25,style: TextStyle(color: Colors.blueAccent,),),
            Text('${user.firstname} ${user.lastname}', textScaleFactor: 1.9,style: TextStyle(color: Colors.blueAccent),),
            Text('Email: ${user.email}'),
            Container(
              child: user.urlToImage != null ? Image.network(user.urlToImage) : _image == null
                  ? Text('No image selected.')
                  : Image.file(_image),
            ),
            RaisedButton(
              onPressed: () {
                getImage();
              },
//                              tooltip: 'Pick Image',
              child: Icon(Icons.add_a_photo),
            ),
          ],
        ),
      ),
    );
  }

}