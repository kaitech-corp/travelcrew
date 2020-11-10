import 'dart:io';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../loading.dart';



class AddNewLodging extends StatefulWidget {

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final Trip trip;
  AddNewLodging({this.trip});
  bool loading = false;
  @override
  _AddNewLodgingState createState() => _AddNewLodgingState();

}
class _AddNewLodgingState extends State<AddNewLodging> {

  final _formKey = GlobalKey<FormState>();
  String lodgingType = '';
  String comment = '';
  String link = '';
  // File _image;
  File urlToImage;
  bool timePickerVisible = false;
  // final ImagePicker _picker = ImagePicker();
  //
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


    return widget.loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: const Text('Add Lodging'),
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
                  setState(() => lodgingType = val);
                },
                enableInteractiveSelection: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Hotel, Airbnb, etc",
                ),
                textCapitalization: TextCapitalization.words,
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
                  labelText: "Link",
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
              ),
                  const Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  ),
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
//                     child: _image == null
//                         ? Text('No image selected.')
//                         : Image.file(_image),
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width,
//                       maxHeight: 300,
//                     ),
//                   ),
//                   RaisedButton(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     onPressed: () {
//                       getImage();
//                     },
// //                              tooltip: 'Pick Image',
//                     child: Icon(Icons.add_a_photo),
//                   ),
//               timePickerVisible ? TimePickers()
//                   : ButtonTheme(
//                 minWidth: 150,
//                 child: RaisedButton(
//                   shape:  RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     'Arrive/Leave Time',
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       timePickerVisible = true;
//                     });
//                   },
//                 ),
//               ),
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
                      String message = 'A new lodging has been added to ${widget.trip.tripName}';
                      bool ispublic = widget.trip.ispublic;
                      await DatabaseService().addNewLodgingData(
                          comment,
                          displayName,
                          documentID,
                          link,
                          lodgingType,
                          uid,
                          urlToImage,
                          tripName,
                          startTime.value,
                          endTime.value,
                      );
                      widget.trip.accessUsers.forEach((f)  =>  CloudFunction().addNewNotification(
                        message: message,
                        documentID: documentID,
                        type: 'Lodging',
                        ownerID: f,
                        ispublic: ispublic,
                      ));
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