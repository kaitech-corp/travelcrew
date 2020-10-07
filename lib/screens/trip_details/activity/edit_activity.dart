import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';



class EditActivity extends StatefulWidget {

  var userService = locator<UserService>();
  final ActivityData activity;
  final Trip trip;
  EditActivity({this.activity, this.trip});

  @override
  _EditActivityState createState() => _EditActivityState();

}
class _EditActivityState extends State<EditActivity> {

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File _image;


  Future getImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);

    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = false;


    String displayName = widget.activity.displayName;
    String link = widget.activity.link;
    String activityType = widget.activity.activityType;
    String comment = widget.activity.comment;


    return loading ? Loading() : Scaffold(
        appBar: AppBar(
          title: Text('Add Lodging'),
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
                      onSaved: (val){
                        setState(() => activityType = val);
                      },
                      enableInteractiveSelection: true,
                      initialValue: activityType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "snorkeling, festival, restuarant, etc",
                      ),
                      // ignore: missing_return
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an activity.';
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    ),
                    TextFormField(
                      onSaved: (val){
                        setState(() => link = val);
                      },
                      enableInteractiveSelection: true,
                      maxLines: 2,
                      initialValue: link,
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
                      onSaved: (val){
                        setState(() => comment = val);
                      },
                      enableInteractiveSelection: true,
                      obscureText: false,
                      initialValue: comment,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Description",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    ),
                    widget.activity.urlToImage == null ? Container(
                      child: _image == null
                          ? Text('No image selected.')
                          : Image.file(_image),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300,
                      ),
                    ):
                    Container(
                      child: _image == null
                          ? Image.network(widget.activity.urlToImage)
                          : Image.file(_image),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        maxHeight: 300,
                      ),
                    ),
                    RaisedButton(
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
                        onPressed: () async{
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            form.save();
                            String documentID = widget.trip.documentId;
                            String fieldID = widget.activity.fieldID;

                            setState(() => loading =true);
                            String message = 'An activity has been modified within ${widget.trip.location}';

                            DatabaseService().editActivityData(comment, displayName, documentID, link, activityType, _image, fieldID);
                            widget.trip.accessUsers.forEach((f) =>  CloudFunction().addNewNotification(
                                message: message,
                                documentID: documentID,
                                type: 'Activity',
                                uidToUse: f));
                            setState(() {
                              loading = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                        color: Colors.lightBlue,
                        child: const Text(
                            'Save',
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