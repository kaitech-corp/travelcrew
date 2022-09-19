import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/custom_objects.dart';
import '../../models/trip_model.dart';
import '../../services/analytics_service.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/calendar_widget.dart';
import '../alerts/alert_dialogs.dart';
import 'google_autocomplete.dart';

GoogleData? googleData;

/// Add trip page
class AddTripPage extends StatefulWidget {

  const AddTripPage({Key? key, this.addedLocation}) : super(key: key);

  //When using google places this object will pass on the location.
  final String? addedLocation;


  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

final AnalyticsService _analyticsService = AnalyticsService();
final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();
final TextEditingController myController = TextEditingController();
final ValueNotifier<GoogleData> googleData2 = ValueNotifier<GoogleData>(googleData!);

class _AddTripPageState extends State<AddTripPage> {
  UserPublicProfile currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  final ValueNotifier<String> startDate = ValueNotifier<String>('');
  final ValueNotifier<String> endDate = ValueNotifier<String>('');
  final ValueNotifier<Timestamp> startDateTimestamp = ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp = ValueNotifier<Timestamp>(Timestamp.now());


  @override
  void initState() {
    super.initState();
    myController.clear();
    if(widget.addedLocation != null){
      myController.text = widget.addedLocation!;
    }
  }

  @override
  void dispose() {
    startDate.dispose();
    startDateTimestamp.dispose();
    endDate.dispose();
    endDateTimestamp.dispose();
    super.dispose();
  }


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool gotDataBool = false;


  String comment = '';
  String displayName = '';
  String documentId = '';
  String firstName = '';
  String lastName = '';
  bool ispublic = true;
  String tripName = '';
  String location = '';
  String ownerID = '';
  String travelType = '';
  File? urlToImage;



  void updateGoogleDataValueNotifier() {
    googleData2.value = GoogleData();
  }

  Future<void> getImageAddTrip() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery,imageQuality: 80);


    setState(() {
      _image = File(image!.path);
      urlToImage = File(_image!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric( horizontal: 16.0),
        child: Builder(
            builder: (BuildContext context) => Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                      TextFormField(
                          enableInteractiveSelection: true,
                          textCapitalization: TextCapitalization.words,
                          initialValue: '',
                          decoration:
                          InputDecoration(
                              labelText: AppLocalizations.of(context)!.addTripNameLabel,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                              )
                          ),
                          // ignore: missing_return
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return AppLocalizations.of(context)!.addTripNameValidator;
                              // ignore: missing_return
                            }
                            return null;
                          },
                          onChanged: (String val) =>
                          {
                            tripName = val,
                          }
                      ),
                      TextFormField(
                          enableInteractiveSelection: true,
                          textCapitalization: TextCapitalization.words,
                          initialValue: '',
                          decoration:
                          InputDecoration(labelText: AppLocalizations.of(context)!.addTripTypeLabel,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                              )
                          ),
                          // ignore: missing_return
                          validator: (String? value) {
                            if (value?.isEmpty ?? true) {
                              return AppLocalizations.of(context)!.addTripTypeValidator;
                              // ignore: missing_return
                            }
                            return null;
                          },
                          onChanged: (String val) => <String>{travelType = val,}
                      ),
                      TextFormField(
                        controller: myController,
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(labelText:AppLocalizations.of(context)!.addTripLocation,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                            )
                        ),
                        validator: (String? value) {
                          if (value?.isEmpty ?? true) {
                            return AppLocalizations.of(context)!.addTripLocationValidator;
                            // ignore: missing_return
                          }
                          return null;
                        },
                        onChanged: (String value){
                          location = value;
                        },
                        // onSaved: (value){
                        //     myController.text = value;
                        // },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: GooglePlaces(homeScaffoldKey: homeScaffoldKey,searchScaffoldKey: searchScaffoldKey,controller: myController,),
                      ),
                      CalendarWidget(
                        startDate: startDate,
                        startDateTimeStamp: startDateTimestamp,
                        endDate: endDate,
                        endDateTimeStamp: endDateTimestamp,
                        context: context,
                        showBoth: true,
                      ),
                      SwitchListTile(
                          title: Text(AppLocalizations.of(context)!.addTripPublic),
                          value: ispublic,
                          onChanged: (bool val) =>
                          {
                            setState((){
                              ispublic = val;
                            }),
                          }
                      ),
                      if (_image != null) Align(
                          alignment: Alignment.topRight,
                          child: IconButton(icon: const Icon(Icons.clear),iconSize: 30, onPressed: (){ setState(() {
                            _image = null;
                            urlToImage = null;
                          });})) else Container(),
                      Container(
                        child: _image == null
                            ? Text(AppLocalizations.of(context)!.addTripImageMessage,style: Theme.of(context).textTheme.headline6,)
                            : Image.file(_image!),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            getImageAddTrip();
                          },
//                              tooltip: 'Pick Image',
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Text(AppLocalizations.of(context)!.addTripDescriptionMessage,style: Theme.of(context).textTheme.subtitle1,),
                      ),
                      TextFormField(
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                            ),
                            border: const OutlineInputBorder(),
                            hintText: AppLocalizations.of(context)!.addTripAddDescriptionMessage,
                            hintStyle: Theme.of(context).textTheme.subtitle1
                        ),
                        style: Theme.of(context).textTheme.subtitle1,
                        onChanged: (String val){
                          comment = val;
                        },
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // splitWiseAPI();
                              final FormState? form = _formKey.currentState;
                              form?.save();
                              if (form!.validate()) {
                                try {
                                  final String action = AppLocalizations.of(context)!.addTripSavingDataMessage;
                                  CloudFunction().logEvent(action);
                                  DatabaseService().addNewTripData(
                                      Trip(
                                        accessUsers: <String>[userService.currentUserID],
                                        comment: comment,
                                        endDate: endDate.value,
                                        endDateTimeStamp:endDateTimestamp.value,
                                        startDateTimeStamp: startDateTimestamp.value,
                                        ispublic: ispublic,
                                        location: myController.text,
                                        startDate: startDate.value,
                                        travelType: travelType,
                                        tripGeoPoint: googleData2.value.geoLocation!,
                                        tripName: tripName, ownerID: '', displayName: '', dateCreatedTimeStamp: Timestamp.now(), urlToImage: '', documentId: '', favorite: <String>[],
                                      ),
                                      urlToImage,
                                      );
                                }  catch (e) {
                                  CloudFunction().logError('Error adding new Trip catch statement:  ${e.toString()}');
                                  _analyticsService.writeError('Error adding new Trip catch statement:  ${e.toString()}');
                                  TravelCrewAlertDialogs().newTripErrorDialog(context);
                                }
                                myController.text = '';
                                myController.clear();
                                form.reset();
                                setState(() {
                                  _image = null;
                                  ispublic =true;
                                });
                                // TravelCrewAlertDialogs().addTripAlert(context);
                                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
                              }
                            },
                            child: Text(addTripAddTripButton()),
                          )
                      ),
                    ]))));
  }
}
