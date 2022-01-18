
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/lodging_model.dart';
import '../../../models/trip_model.dart';
import '../../add_trip/google_places.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/calendar_widget.dart';
import '../../../services/widgets/reusableWidgets.dart';



class AddNewLodging extends StatefulWidget {

  final Trip trip;
  AddNewLodging({this.trip});

  @override
  _AddNewLodgingState createState() => _AddNewLodgingState();

}
class _AddNewLodgingState extends State<AddNewLodging> {

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();

  final ValueNotifier<String> startTime = ValueNotifier('');
  final ValueNotifier<String> endTime = ValueNotifier('');
  final ValueNotifier<Timestamp> startDateTimeStamp = ValueNotifier(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimeStamp = ValueNotifier(Timestamp.now());
  final TextEditingController controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String displayName = '';
  String documentID = '';
  String lodgingType = '';
  String comment = '';
  String link = '';
  String uid = '';
  bool ispublic;
  bool timePickerVisible = false;

  @override
  void initState() {
    endDateTimeStamp.value =  widget.trip.endDateTimeStamp;
    startDateTimeStamp.value = widget.trip.startDateTimeStamp;
    displayName = currentUserProfile.displayName;
    documentID = widget.trip.documentId;
    uid = userService.currentUserID;
    ispublic = widget.trip.ispublic;
    super.initState();
  }

  @override
  void dispose() {
    endTime.dispose();
    startTime.dispose();
    controller.dispose();
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: TextFormField(
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
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: TextFormField(
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
                CalendarWidget(
                  startDateTimeStamp: startDateTimeStamp,
                  endDateTimeStamp: endDateTimeStamp,
                  showBoth: true,),
                timePickerVisible ? TimePickers(lodging: true,startTime: startTime,endTime: endTime,) :
                Container(
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

              String message = 'A new lodging has been added to ${widget.trip.tripName}';

              try {
                String action = 'Saving new lodging for $documentID';
                CloudFunction().logEvent(action);
                await DatabaseService().addNewLodgingData(documentID,
                    LodgingData(
                      comment: comment.trim(),
                      displayName: displayName,
                      endTime: endTime.value,
                      endDateTimestamp: endDateTimeStamp.value,
                      link: link,
                      location: controller.text,
                      lodgingType: lodgingType,
                      startTime: startTime.value,
                      startDateTimestamp: startDateTimeStamp.value,
                      uid: uid,
                      voters: [],
                    ));
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