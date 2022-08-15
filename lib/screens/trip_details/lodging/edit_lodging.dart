
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/reusableWidgets.dart';
import '../../add_trip/google_places.dart';

/// Edit lodging data
class EditLodging extends StatefulWidget {

  final LodgingData lodging;
  final Trip trip;
  EditLodging({required this.lodging, required this.trip});

  @override
  _EditLodgingState createState() => _EditLodgingState();

}
class _EditLodgingState extends State<EditLodging> {

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<String> startTime = ValueNotifier('');
  final ValueNotifier<String> endTime = ValueNotifier('');
  final ValueNotifier<Timestamp> startDateTimestamp = ValueNotifier(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp = ValueNotifier(Timestamp.now());
  final TextEditingController controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? link;
  String? lodgingType;
  String? comment;
  late String documentID;
  late String fieldID;
  bool calendarVisible = false;
  bool timePickerVisible = false;


  @override
  void initState() {
    controller.text = widget.lodging.location ?? '';
    endDateTimestamp.value = widget.lodging.endDateTimestamp ?? widget.trip.endDateTimeStamp!;
    startDateTimestamp.value = widget.lodging.startDateTimestamp ?? widget.trip.startDateTimeStamp!;
    link = widget.lodging.link;
    lodgingType = widget.lodging.lodgingType;
    comment = widget.lodging.comment;
    startTime.value = widget.lodging.startTime!;
    endTime.value = widget.lodging.endTime!;
    documentID = widget.trip.documentId!;
    fieldID = widget.lodging.fieldID!;
    super.initState();
  }

  @override
  void dispose() {
   controller.dispose();
   endDateTimestamp.dispose();
   startDateTimestamp.dispose();
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
            title: Text('Edit Lodging',style: Theme.of(context).textTheme.headline5,),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Builder(
              builder: (context) => Form(
                key: _formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        onSaved: (val){
                          setState(() => lodgingType = val);
                        },
                        textCapitalization: TextCapitalization.sentences,
                        enableInteractiveSelection: true,
                        initialValue: lodgingType,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                          ),
                          labelText: "Hotel, Airbnb, etc",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return 'Please enter a lodging type.';
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
                        initialValue: link,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                          ),
                          labelText: "Link",
                        ),
                        // ignore: missing_return
                        validator: (value) {
                          if ( (value?.isNotEmpty ?? false) && !value!.startsWith('https')){
                            return 'Please enter a valid link with including https.';
                          }
                        },
                          autovalidateMode: AutovalidateMode.onUserInteraction
                      ),
                      const Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      ),
                      TextFormField(
                        onSaved: (val){
                          setState(() => comment = val);
                        },
                        textCapitalization: TextCapitalization.sentences,
                        enableInteractiveSelection: true,
                        obscureText: false,
                        initialValue: comment,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context), width: 1.0),
                          ),
                          labelText: "Description",
                        ),
                        maxLines: 5,
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
                            labelText: "Address",
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
                      calendarVisible ? CalendarWidget(
                        startDateTimeStamp: startDateTimestamp,
                        endDateTimeStamp: endDateTimestamp,
                        showBoth: true,):
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: Text('Edit Dates',style: Theme.of(context).textTheme.subtitle1,
                          ),
                          onPressed: () {
                            setState(() {
                              calendarVisible = true;
                            });
                          },
                        ),
                      ),
                      timePickerVisible ? TimePickers(lodging: true,startTime: startTime,endTime: endTime,) :
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                    ]
                ),
              ),
            ),
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            final form = _formKey.currentState!;
            if (form.validate()) {
              form.save();
              String message = 'A lodging option has been modified within ${widget.trip.tripName}';

              try {
                DatabaseService().editLodgingData(
                  comment: comment,
                  documentID: documentID,
                  endDateTimestamp: endDateTimestamp.value,
                  endTime: endTime.value,
                  fieldID: fieldID,
                  link: link,
                  location: controller.text,
                  lodgingType: lodgingType,
                  startDateTimestamp: startDateTimestamp.value,
                  startTime: startTime.value,
                );
              } on Exception catch (e) {
                CloudFunction().logError('Error adding new Trip:  ${e.toString()}');
              }
              try {
                String action = 'Sending notifications for $documentID lodging';
                CloudFunction().logEvent(action);
                widget.trip.accessUsers!.forEach((f) {
                  if (f != currentUserProfile.uid) {
                    CloudFunction().addNewNotification(
                      message: message,
                      documentID: documentID,
                      type: 'Lodging',
                      uidToUse: f,
                      ownerID: currentUserProfile.uid,
                    );
                  }
                });
              } catch(e){
                CloudFunction().logError('Error sending notifications for edited lodging:  ${e.toString()}');
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