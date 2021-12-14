import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/activity_model.dart';
import '../../../models/trip_model.dart';
import '../../add_trip/google_places.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/locator.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/in_app_review.dart';
import '../../../services/widgets/loading.dart';
import '../../../services/widgets/reusableWidgets.dart';

class AddNewActivity extends StatefulWidget {


  final Trip trip;
  AddNewActivity({this.trip});

  @override
  AddNewActivityState createState() => AddNewActivityState();

}



class AddNewActivityState extends State<AddNewActivity> {

  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final _formKey = GlobalKey<FormState>();

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<Timestamp> startDateTimestamp =ValueNotifier(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp =ValueNotifier(Timestamp.now());
  final ValueNotifier<String> startTime = ValueNotifier('');
  final ValueNotifier<String> endTime = ValueNotifier('');
  final TextEditingController controller = TextEditingController();



  String activityType = '';
  String comment = '';
  String link = '';
  String location = '';
  File urlToImage;
  bool timePickerVisible = false;

  @override
  void initState() {
   controller.clear();
    super.initState();
  }
  @override
  void dispose() {
    startTime.dispose();
    endTime.dispose();
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    bool loading = false;

    return loading ? Loading() : GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Add Activity',style: Theme.of(context).textTheme.headline5,),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Builder(
              builder: (context) => Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
                          onChanged: (val){
                            setState(() => activityType = val);
                          },
                          enableInteractiveSelection: true,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                            ),
                            labelText: "Snorkeling, Festival, Restaurant, etc",
                          ),
                          // ignore: missing_return
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a lodging type.';
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
                          onChanged: (val){
                            setState(() => link = val);
                          },
                          enableInteractiveSelection: true,
                          // maxLines: 2,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                            ),
                            labelText: "Link",
                          ),
                          // ignore: missing_return
                          validator: (value) {
                            if ( value.isNotEmpty && !value.startsWith('https')){
                              return 'Please enter a valid link with including https.';
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
                          controller: controller,
                          enableInteractiveSelection: true,
                          // maxLines: 2,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                            ),
                            labelText: "Location (i.e. Address )",
                          ),
                          // ignore: missing_return
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: GooglePlaces(homeScaffoldKey: homeScaffoldKey,searchScaffoldKey: searchScaffoldKey,controller: controller,),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Schedule',style: Theme.of(context).textTheme.headline6,),
                      ),
                      Container(height: 2,color: Colors.black,),
                      CalendarWidget(startDateTimeStamp: startDateTimestamp,endDateTimeStamp:endDateTimestamp,showBoth: true,),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      timePickerVisible ? TimePickers(lodging: false,startTime: startTime,endTime: endTime,)
                      : Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 30.0),
                          child: ButtonTheme(
                            child: ElevatedButton(
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
                      ),
                    ]
                ),
              ),
            ),
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            String documentID = widget.trip.documentId;
            String message = 'A new activity has been added to ${widget.trip.tripName}';
            bool ispublic = widget.trip.ispublic;

            final form = _formKey.currentState;
            if (form.validate()) {
              try {
                String action = 'Saving new activity';
                CloudFunction().logEvent(action);
                await DatabaseService().addNewActivityData(
                    ActivityData(
                        activityType: activityType,
                        comment: comment.trim(),
                        startDateTimestamp: (startDateTimestamp.value == null) ? widget.trip.startDateTimeStamp : startDateTimestamp.value,
                        endDateTimestamp: (endDateTimestamp.value == null) ? widget.trip.startDateTimeStamp : endDateTimestamp.value,
                        displayName: currentUserProfile.displayName,
                        endTime: endTime.value,
                        fieldID: '',
                        link: link,
                        location: controller.text,
                        startTime: startTime.value,
                        uid: userService.currentUserID,
                        voters: []), documentID);
              } on Exception catch (e) {
                CloudFunction().logError('Error adding new activity:  ${e.toString()}');
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
                CloudFunction().logError('Error sending notifications for new activity:  ${e.toString()}');
              }

              setState(() {
                loading = false;
              });
              navigationService.pop();
              DatabaseService().appReviewExists(TCFunctions().appReviewDocID()).then((value) => {
                if(!value){
                  InAppReviewClass().requestReviewFunc(),
                  CloudFunction().addReview(docID: TCFunctions().appReviewDocID()),
                }
              });

            }
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }


}