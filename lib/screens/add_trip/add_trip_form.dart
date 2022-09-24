import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../blocs/add_trip_bloc/add_trip_bloc.dart';
import '../../blocs/add_trip_bloc/add_trip_event.dart';
import '../../blocs/add_trip_bloc/add_trip_state.dart';
import '../../models/custom_objects.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/image_picker_cropper/image_picker_cropper.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/calendar_widget.dart';
import '../alerts/alert_dialogs.dart';
import 'google_autocomplete.dart';

// GoogleData? googleData;

/// Add trip page
class AddTripForm extends StatefulWidget {
  const AddTripForm({Key? key, this.addedLocation}) : super(key: key);

  //When using google places this object will pass on the location.
  final String? addedLocation;

  @override
  State<AddTripForm> createState() => _AddTripFormState();
}

final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();
final ValueNotifier<GoogleData> googleData =
    ValueNotifier<GoogleData>(GoogleData());
final TextEditingController locationController = TextEditingController();

class _AddTripFormState extends State<AddTripForm> {
  UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  final ValueNotifier<String> startDate = ValueNotifier<String>('');
  final ValueNotifier<String> endDate = ValueNotifier<String>('');
  final ValueNotifier<Timestamp> startDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<Timestamp> endDateTimestamp =
      ValueNotifier<Timestamp>(Timestamp.now());
  final ValueNotifier<File> _urlToImage = ValueNotifier<File>(File(''));
  final TextEditingController commentController = TextEditingController();
  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController travelTypeController = TextEditingController();

  bool ispublic = true;

  late AddTripBloc _addTripBloc;

  @override
  void initState() {
    super.initState();
    _addTripBloc = BlocProvider.of<AddTripBloc>(context);
    if (widget.addedLocation != null) {
      locationController.text = widget.addedLocation!;
    }
    tripNameController.addListener(_onTripNameChange);
    travelTypeController.addListener(_onTripTypeChange);
    _urlToImage.addListener(_onTripImageChange);
  }

  @override
  void dispose() {
    // startDate.dispose();
    // startDateTimestamp.dispose();
    // endDate.dispose();
    // endDateTimestamp.dispose();
    // commentController.dispose();
    // locationController.dispose();
    // tripNameController.dispose();
    // travelTypeController.dispose();
    // _urlToImage.dispose();
    super.dispose();
  }

  bool imagePicked = false;

  void updateGoogleDataValueNotifier() {
    googleData.value = GoogleData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddTripBloc, AddTripState>(
        listener: (BuildContext context, AddTripState state) {
      if (state.isFailure) {
        TravelCrewAlertDialogs().newTripErrorDialog(context);
      }
      if (state.isSuccess) {}
    }, child: BlocBuilder<AddTripBloc, AddTripState>(
            builder: (BuildContext context, AddTripState state) {
      return Builder(
          builder: (BuildContext context) => Form(
                  child: Column(children: <Widget>[
                TextFormField(
                  controller: tripNameController,
                  enableInteractiveSelection: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.addTripNameLabel,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor()
                                .colorOpposite(context)),
                      )),
                  validator: (String? value) {
                    if (!state.isTripNameValid) {
                      return AppLocalizations.of(context)!
                          .addTripNameValidator;
                    }
                  },
                  autovalidateMode: AutovalidateMode.always,
                ),
                TextFormField(
                  controller: travelTypeController,
                  enableInteractiveSelection: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.addTripTypeLabel,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor()
                                .colorOpposite(context)),
                      )),
                  validator: (String? value) {
                    if (!state.isTripTypeValid) {
                      return AppLocalizations.of(context)!
                          .addTripTypeValidator;
                      // ignore: missing_return
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.always,
                ),
                TextFormField(
                  controller: locationController,
                  enableInteractiveSelection: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.addTripLocation,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor()
                                .colorOpposite(context)),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: GooglePlaces(
                    homeScaffoldKey: homeScaffoldKey,
                    searchScaffoldKey: searchScaffoldKey,
                    controller: locationController,
                  ),
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
                    title:
                        Text(AppLocalizations.of(context)!.addTripPublic),
                    value: ispublic,
                    onChanged: (bool val) => <void>{
                          setState(() {
                            ispublic = val;
                          }),
                        }),
                if (imagePicked)
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          icon: const Icon(Icons.clear,color: Colors.black,),
                          iconSize: 30,
                          onPressed: () {
                            setState(() {
                              imagePicked = false;
                            });
                          })),
                Container(
                    child: imagePicked
                        ? Image.file(_urlToImage.value)
                        : Text(
                            AppLocalizations.of(context)!
                                .addTripImageMessage,
                            style: Theme.of(context).textTheme.headline6,
                          )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      _urlToImage.value = await ImagePickerAndCropper().uploadImage(_urlToImage);
                      print(_urlToImage.value.path);
                    },
//                              tooltip: 'Pick Image',
                    child: const Icon(Icons.add_a_photo),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    AppLocalizations.of(context)!.addTripDescriptionMessage,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                TextFormField(
                  controller: commentController,
                  enableInteractiveSelection: true,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor()
                                .colorOpposite(context)),
                      ),
                      border: const OutlineInputBorder(),
                      hintText: AppLocalizations.of(context)!
                          .addTripAddDescriptionMessage,
                      hintStyle: Theme.of(context).textTheme.subtitle1),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (isButtonEnabled(state)) {
                          _onFormSubmitted();
                          navigationService.pushNamedAndRemoveUntil(
                              LaunchIconBadgerRoute);
                        }
                      },
                      child: Text(addTripAddTripButton()),
                    )),
              ])));
    }));
  }

  bool isButtonEnabled(AddTripState state) {
    return state.isFormValid && !state.isSubmitting;
  }

  void _onTripNameChange(){
    _addTripBloc.add(AddTripNameChange(tripName: tripNameController.text));
  }
  void _onTripTypeChange(){
    _addTripBloc.add(AddTripTypeChanged(travelType: travelTypeController.text));
  }
  void _onTripImageChange(){
    _addTripBloc.add(AddTripImageAdded(urlToImage: _urlToImage.value));
    if(_urlToImage.value.path.isNotEmpty){
      setState(() {
        imagePicked = true;
      });
    }
  }

  void _onFormSubmitted() {
    _addTripBloc.add(AddTripButtonPressed(
        commentController.text,
        endDate.value,
        endDateTimestamp.value,
        startDateTimestamp.value,
        ispublic,
        locationController.text,
        startDate.value,
        googleData.value.geoLocation,
        _urlToImage.value,
        tripName: tripNameController.text,
        travelType: travelTypeController.text));
  }
}
