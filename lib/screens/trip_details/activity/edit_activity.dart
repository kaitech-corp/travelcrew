
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/activity_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/locator.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/reusableWidgets.dart';
import '../../add_trip/google_places.dart';



class EditActivity extends StatefulWidget {

  final ActivityData activity;
  final Trip trip;
  EditActivity({required this.activity, required this.trip});

  @override
  _EditActivityState createState() => _EditActivityState();

}
class _EditActivityState extends State<EditActivity> {
  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController controllerType = TextEditingController();
  final TextEditingController controllerLink = TextEditingController();
  final TextEditingController controllerComment = TextEditingController();
  final TextEditingController controllerLocation = TextEditingController();
  final ValueNotifier<String> startTime = ValueNotifier('');
  final ValueNotifier<String> endTime = ValueNotifier('');
  final ValueNotifier<Timestamp> startDateTimestamp =ValueNotifier(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp =ValueNotifier(Timestamp.now());

  final _formKey = GlobalKey<FormState>();

  bool calendarVisible = false;
  bool timePickerVisible = false;

  late String displayName;
  late String documentID;
  late String fieldID;


  @override
  void initState() {
    documentID = widget.trip.documentId!;
    fieldID = widget.activity.fieldID!;
    startDateTimestamp.value = widget.activity.startDateTimestamp ?? widget.trip.startDateTimeStamp!;
    endDateTimestamp.value = widget.activity.endDateTimestamp ?? widget.trip.startDateTimeStamp!;
    controllerComment.text = widget.activity.comment ?? '';
    controllerLink.text = widget.activity.link ?? '';
    controllerLocation.text = widget.activity.location!;
    controllerType.text = widget.activity.activityType!;
    startTime.value = widget.activity.startTime!;
    endTime.value = widget.activity.endTime!;
    displayName = widget.activity.displayName!;

    super.initState();
  }
  @override
  void dispose() {
    controllerComment.dispose();
    controllerLink.dispose();
    controllerLocation.dispose();
    controllerType.dispose();
    endTime.dispose();
    startTime.dispose();
    startDateTimestamp.dispose();
    endDateTimestamp.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Activity',style: Theme.of(context).textTheme.headline5,),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) => Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: controllerType,
                        enableInteractiveSelection: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "snorkeling, festival, restaurant, etc",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return 'Please enter an activity.';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      TextFormField(
                        controller: controllerLink,
                        enableInteractiveSelection: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Link",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if ( (value?.isNotEmpty ?? false) && !value!.startsWith('https')){
                            return 'Please enter a valid link with including https.';
                          }
                        },
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      TextFormField(
                        controller: controllerComment,
                        enableInteractiveSelection: true,
                        obscureText: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Description",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: TextFormField(
                          controller: controllerLocation,
                          enableInteractiveSelection: true,
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
                          child: GooglePlaces(
                            homeScaffoldKey: homeScaffoldKey,
                            searchScaffoldKey: searchScaffoldKey,
                            controller: controllerLocation,),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Schedule',style: Theme.of(context).textTheme.headline6,),
                      ),
                      Container(height: 2,color: Colors.black,),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      calendarVisible ? CalendarWidget(
                        startDateTimeStamp: startDateTimestamp,
                        endDateTimeStamp:endDateTimestamp,
                        showBoth: true,):
                      ElevatedButton(
                        child:  Text(
                          'Edit Date', style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onPressed: () {
                          setState(() {
                            calendarVisible = true;
                          });
                        },
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      timePickerVisible ? TimePickers(lodging: false,startTime: startTime,endTime: endTime,)
                          : ElevatedButton(
                            child:  Text(
                              'Start/End Time', style: Theme.of(context).textTheme.subtitle1,
                            ),
                            onPressed: () {
                              setState(() {
                                timePickerVisible = true;
                              });
                            },
                          ),
                    ]
                ),
              ),
            ),
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            final form = _formKey.currentState!;
            if (form.validate()) {
              // form.save();
              String message = 'An activity has been modified within ${widget.trip.tripName}';
              try {
                String action = 'Saving edited activity data';
                CloudFunction().logEvent(action);
                DatabaseService().editActivityData(
                  comment: controllerComment.text,
                  displayName: displayName,
                  documentID: documentID,
                  link: controllerLink.text,
                  activityType: controllerType.text,
                  fieldID: fieldID,
                  location: controllerLocation.text,
                  startDateTimestamp: (startDateTimestamp.value == null) ? widget.trip.startDateTimeStamp : startDateTimestamp.value,
                  endDateTimestamp: (endDateTimestamp.value == null) ? widget.trip.startDateTimeStamp : endDateTimestamp.value,
                  startTime: startTime.value,
                  endTime: endTime.value,
                );
              } on Exception catch (e) {
                CloudFunction().logError('Error saving edited activity data:  ${e.toString()}');
              }

              try {
                String action = 'Send notifications for edited activity';
                CloudFunction().logEvent(action);
                widget.trip.accessUsers!.forEach((f) {
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
              } catch (e) {
                CloudFunction().logError('Error sending notifications for edited activities:  ${e.toString()}');
              }
            }
            navigationService.pop();
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }


}