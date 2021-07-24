import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';

import '../../../services/widgets/loading.dart';



class AddNewLodging extends StatefulWidget {

  final Trip trip;
  AddNewLodging({this.trip});

  @override
  _AddNewLodgingState createState() => _AddNewLodgingState();

}
class _AddNewLodgingState extends State<AddNewLodging> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  String lodgingType = '';
  String comment = '';
  String link = '';
  File urlToImage;
  bool timePickerVisible = false;



  @override
  Widget build(BuildContext context) {


    return loading ? Loading() :
    GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Lodging',style: Theme.of(context).textTheme.headline5,),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                TextFormField(
                  onChanged: (val){
                    setState(() => lodgingType = val);
                  },
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                    ),
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
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                    ),
                    labelText: "Link",
                  ),
                  // ignore: missing_return
                  validator: (value) {
                    if ( value.trim().isNotEmpty && !value.startsWith('https')){
                      return 'Please enter a valid link including https.';
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
                ),
                    const Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    ),
                timePickerVisible ? TimePickers()
                    : Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 30.0),
                      child: ButtonTheme(
                  minWidth: 150,
                  child: ElevatedButton(
                      child: Text('CheckIn/Checkout',style: Theme.of(context).textTheme.subtitle1,
                      ),
                      onPressed: () {
                        setState(() {
                          timePickerVisible = true;
                        });
                      },
                  ),
                ),
                ),
                  ]),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final form = _formKey.currentState;
            if (form.validate()) {
              String displayName = currentUserProfile.displayName;
              String documentID = widget.trip.documentId;
              String uid = userService.currentUserID;
              String tripName = widget.trip.location;
              String message = 'A new lodging has been added to ${widget.trip.tripName}';
              bool ispublic = widget.trip.ispublic;
              try {
                String action = 'Saving new lodging for $documentID';
                CloudFunction().logEvent(action);
                await DatabaseService().addNewLodgingData(
                  comment.trim(),
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
              } on Exception catch (e) {
                CloudFunction().logError('Error adding new Lodging:  ${e.toString()}');
              }
              try {
                String action = 'Sending notifications for $documentID lodging';
                CloudFunction().logEvent(action);
                widget.trip.accessUsers.forEach((f)  {
                  if(f != currentUserProfile.uid){
                    CloudFunction().addNewNotification(
                      message: message,
                      documentID: documentID,
                      type: 'Lodging',
                      uidToUse: f,
                      ownerID: currentUserProfile.uid,
                      ispublic: ispublic,
                    );
                  }
                });
              } on Exception catch (e) {
                CloudFunction().logError('Error sending notifications for new lodging:  ${e.toString()}');
              }
              navigationService.pop();
            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}