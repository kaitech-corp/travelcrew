import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';

class AddNewActivity extends StatefulWidget {


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
  // File _image;
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
            padding: const EdgeInsets.all(8),
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
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                          ),
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
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                          ),
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
                        textCapitalization: TextCapitalization.sentences,
                        obscureText: false,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                          ),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 30.0),
                        child: ButtonTheme(
                          child: RaisedButton(
                            shape:  RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:  Text(
                              'Start/End Time', style: Theme.of(context).textTheme.subtitle1,
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
                              String displayName = currentUserProfile.displayName;
                              String documentID = widget.trip.documentId;
                              String uid = userService.currentUserID;
                              String tripName = widget.trip.location;
                              setState(() => loading =true);
                              String message = 'A new activity has been added to ${widget.trip.tripName}';
                              bool ispublic = widget.trip.ispublic;
                              try {
                                String action = 'Saving new activity';
                                CloudFunction().logEvent(action);
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
                              } on Exception catch (e) {
                                CloudFunction().logError(e.toString());
                              }
                              try {
                                String action = 'Send notifications for edited activity';
                                CloudFunction().logEvent(action);
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
                              } on Exception catch (e) {
                                CloudFunction().logError(e.toString());
                              }

                              setState(() {
                                loading = false;
                              });
                              navigationService.pop();
                              DatabaseService().appReviewExists(TCFunctions().appReviewDocID()).then((value) => {
                                if(!value){
                                  // InAppReviewClass().requestReviewFunc(),
                                  // CloudFunction().addReview(docID: TCFunctions().appReviewDocID()),
                                }
                              });

                            }
                          },
                            child: Text(
                              'Add',
                              style: Theme.of(context).textTheme.subtitle1,
                            )
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