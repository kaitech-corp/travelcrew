import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/loading.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/in_app_review.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';

class AddNewActivity extends StatefulWidget {

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final Trip trip;
  AddNewActivity({this.trip});

  @override
  AddNewActivityState createState() => AddNewActivityState();

}
TimeOfDay timeStart = TimeOfDay.now();
TimeOfDay timeEnd = TimeOfDay.now();
final ValueNotifier<String> startTime = ValueNotifier('');
final ValueNotifier<String> endTime = ValueNotifier('');

class AddNewActivityState extends State<AddNewActivity> {

  final _formKey = GlobalKey<FormState>();
  String activityType = '';
  String comment = '';
  String link = '';
  File _image;
  File urlToImage;

  bool timePickerVisible = false;
  // final ImagePicker _picker = ImagePicker();

  // Future getImage() async {
  //   var image = await _picker.getImage(source: ImageSource.gallery,imageQuality: 80);
  //
  //   setState(() {
  //     _image = File(image.path);
  //     urlToImage = _image;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    bool loading = false;

    return loading ? Loading() : GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Activity'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Builder(
              builder: (context) => Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        onChanged: (val){
                          setState(() => activityType = val);
                        },
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "snorkeling, festival, restaurant, etc",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a lodging type.';
                          }
                        },
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      TextFormField(
                        onChanged: (val){
                          setState(() => link = val);
                        },
                        enableInteractiveSelection: true,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Link (i.e. Website/GoogleMaps )",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if ( value.isNotEmpty && !value.startsWith('https')){
                            return 'Please enter a valid link with including https.';
                          }
                        },
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      TextFormField(
                        onChanged: (val){
                          setState(() => comment = val);
                        },
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.words,
                        obscureText: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Description",
                        ),
                        maxLines: 5,
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//                       child: _image == null
//                           ? Text('No image selected.')
//                           : Image.file(_image),
//                       constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width,
//                         maxHeight: 300,
//                       ),
//                     ),
//                     RaisedButton(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       onPressed: () {
//                         getImage();
//                       },
// //                              tooltip: 'Pick Image',
//                       child: Icon(Icons.add_a_photo),
//                     ),
                      timePickerVisible ? TimePickers()
                      : Container(
                        width: SizeConfig.screenWidth*.25,
                        child: ButtonTheme(
                          child: RaisedButton(
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Start/End Time',
                            ),
                            onPressed: () {
                              setState(() {
                                timePickerVisible = true;
                              });
                            },
                          ),
                        ),
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
                              String message = 'A new activity has been added to ${widget.trip.tripName}';
                              bool ispublic = widget.trip.ispublic;
                              await DatabaseService().addNewActivityData(
                                  comment.trim(),
                                  displayName,
                                  documentID,
                                  link,
                                  activityType,
                                  uid,
                                  urlToImage,
                                  tripName,
                                  startTime.value,
                                  endTime.value
                              );
                              widget.trip.accessUsers.forEach((f) {
                              if(f != currentUserProfile.uid){
                                          CloudFunction().addNewNotification(
                                            message: message,
                                            documentID: documentID,
                                            type: 'Activity',
                                            uidToUse: f,
                                            ownerID: currentUserProfile.uid,
                                            ispublic: ispublic,
                                          );
                                        }
                              });

                              setState(() {
                                loading = false;
                              });
                              Navigator.pop(context);
                              DatabaseService().appReviewExists(TCFunctions().AppReviewDocID()).then((value) => {
                                if(!value){
                                  InAppReviewClass().requestReviewFunc()
                                }
                              });

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
      ),
    );
  }


}