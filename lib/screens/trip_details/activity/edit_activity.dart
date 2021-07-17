import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travelcrew/models/activity_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';



class EditActivity extends StatefulWidget {

  final ActivityData activity;
  final Trip trip;
  EditActivity({this.activity, this.trip});

  @override
  _EditActivityState createState() => _EditActivityState();

}
class _EditActivityState extends State<EditActivity> {

  final _formKey = GlobalKey<FormState>();
  File _image;
  bool timePickerVisible = false;


  @override
  Widget build(BuildContext context) {
    bool loading = false;


    String displayName = widget.activity.displayName;
    String link = widget.activity.link;
    String activityType = widget.activity.activityType;
    String comment = widget.activity.comment;
    String startTimeSaved = widget.activity.startTime;
    String endTimeSaved = widget.activity.endTime;


    return loading ? Loading() : GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Activity',style: Theme.of(context).textTheme.headline5,),
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
                      Container(
                        // padding: const EdgeInsets.all(10),
                      ),
                      TextFormField(
                        onSaved: (val){
                          setState(() => activityType = val);
                        },
                        enableInteractiveSelection: true,
                        initialValue: activityType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "snorkeling, festival, restaurant, etc",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an activity.';
                          }
                        },
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      TextFormField(
                        onSaved: (val){
                          setState(() => link = val);
                        },
                        enableInteractiveSelection: true,
                        maxLines: 2,
                        initialValue: link,
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
                        onSaved: (val){
                          setState(() => comment = val);
                        },
                        enableInteractiveSelection: true,
                        obscureText: false,
                        initialValue: comment,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Description",
                        ),
                      ),
                      timePickerVisible ?
                      TimePickers():
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text('Start: $startTimeSaved',style: Theme.of(context).textTheme.subtitle1,),
                                Padding(padding: EdgeInsets.only(top: 2)),
                                Text('End: $endTimeSaved',style: Theme.of(context).textTheme.subtitle1,),
                              ],
                            ),
                            ButtonTheme(
                              minWidth: 150,
                              child: ElevatedButton(
                                child: Text(
                                  'Edit Time',style: Theme.of(context).textTheme.subtitle1,
                                ),
                                onPressed: () {
                                  setState(() {
                                    timePickerVisible = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 30.0, horizontal: 30.0),
                        child: ElevatedButton(
                          onPressed: () async{
                            final form = _formKey.currentState;
                            if (form.validate()) {
                              form.save();
                              String documentID = widget.trip.documentId;
                              String fieldID = widget.activity.fieldID;
                              if(!timePickerVisible){
                                startTime.value = startTimeSaved;
                                endTime.value = endTimeSaved;
                              }
                              setState(() => loading =true);
                              String message = 'An activity has been modified within ${widget.trip.tripName}';
                              try {
                                String action = 'Saving edited activity data';
                                CloudFunction().logEvent(action);
                                DatabaseService().editActivityData(
                                    comment,
                                    displayName,
                                    documentID,
                                    link,
                                    activityType,
                                    _image, fieldID,
                                    startTime.value,
                                    endTime.value,
                                );
                              } on Exception catch (e) {
                                CloudFunction().logError('Error saving edited activity data:  ${e.toString()}');
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
                                    );
                                  }
                                });
                              } on Exception catch (e) {
                                CloudFunction().logError('Error sending notifications for edited activities:  ${e.toString()}');
                              }
                              setState(() {
                                loading = false;
                              });
                              navigationService.pop();
                            }
                          },
                            child: Text(
                              'Save',
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