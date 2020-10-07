import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';

class AddNewActivity extends StatefulWidget {

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final Trip trip;
  AddNewActivity({this.trip});

  @override
  _AddNewActivityState createState() => _AddNewActivityState();

}
class _AddNewActivityState extends State<AddNewActivity> {

  final _formKey = GlobalKey<FormState>();
  String activityType = '';
  String comment = '';
  String link = '';
  File _image;
  File urlToImage;
  final ImagePicker _picker = ImagePicker();

  Future getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
      urlToImage = _image;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = false;

    return loading ? Loading() : Scaffold(
        appBar: AppBar(
          title: Text('Add Activity'),
        ),
        body: SingleChildScrollView(
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    ),
                    TextFormField(
                      onChanged: (val){
                        setState(() => activityType = val);
                      },
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "snorkeling, festival, restuarant, etc",
                      ),
                      // ignore: missing_return
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a lodging type.';
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    ),
                    TextFormField(
                      onChanged: (val){
                        setState(() => link = val);
                      },
                      enableInteractiveSelection: true,
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Link",
                      ),
                      // ignore: missing_return
                      validator: (value) {
                        if ( value.isNotEmpty && !value.startsWith('https')){
                          return 'Please enter a valide link with including https.';
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    ),
                    TextFormField(
                      onChanged: (val){
                        setState(() => comment = val);
                      },
                      enableInteractiveSelection: true,
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: _image == null
                          ? Text('No image selected.')
                          : Image.file(_image),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300,
                      ),
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onPressed: () {
                        getImage();
                      },
//                              tooltip: 'Pick Image',
                      child: Icon(Icons.add_a_photo),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 30.0),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () async{
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            String displayName = widget.currentUserProfile.displayName;
                            String documentID = widget.trip.documentId;
                            String uid = widget.userService.currentUserID;
                            String tripName = widget.trip.location;
                            setState(() => loading =true);
                            String message = 'A new activity has been added to ${widget.trip.location}';
                            bool ispublic = widget.trip.ispublic;

                            await DatabaseService().addNewActivityData(comment, displayName, documentID, link, activityType, uid, urlToImage, tripName);
                            widget.trip.accessUsers.forEach((f)  =>  CloudFunction().addNewNotification(
                              message: message,
                              documentID: documentID,
                              type: 'Activity',
                              ownerID: f,
                              ispublic: ispublic,
                            ));

                            setState(() {
                              loading = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                        color: Colors.lightBlue,
                        child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white, fontSize: 20)
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        )
    );
  }


}