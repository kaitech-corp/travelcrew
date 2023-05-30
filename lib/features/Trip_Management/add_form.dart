import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../blocs/add_trip_bloc/add_trip_bloc.dart';
import '../../blocs/add_trip_bloc/add_trip_event.dart';
import '../../blocs/add_trip_bloc/add_trip_state.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/image_picker_cropper/image_picker_cropper.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/theme/text_styles.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/calendar_widget.dart';
import '../alerts/alert_dialogs.dart';
import 'components/google_autocomplete.dart';

// GoogleData? googleData;

/// Add trip page
class AddTripForm extends StatefulWidget {
  const AddTripForm({
    Key? key,
  }) : super(key: key);

  @override
  State<AddTripForm> createState() => _AddTripFormState();
}

final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> searchScaffoldKey = GlobalKey<ScaffoldState>();
// late ValueNotifier<GoogleData> googleData;
final TextEditingController locationController = TextEditingController();

class _AddTripFormState extends State<AddTripForm> {
  UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController travelTypeController = TextEditingController();

  bool ispublic = true;
  late AddTripBloc _addTripBloc;

  bool get isPopulated =>
      tripNameController.text.isNotEmpty &&
      travelTypeController.text.isNotEmpty;

  bool isAddTripButtonEnabled(AddTripState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _addTripBloc = BlocProvider.of<AddTripBloc>(context);
    tripNameController.addListener(_onTripNameChange);
    travelTypeController.addListener(_onTripTypeChange);
  }

  @override
  void dispose() {
    travelTypeController.dispose();
    tripNameController.dispose();

    locationController.clear();

    super.dispose();
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
                      labelText: AppLocalizations.of(context)!.addTripNameLabel,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
                      )),
                  validator: (String? value) {
                    if (!state.isTripNameValid) {
                      return AppLocalizations.of(context)!.addTripNameValidator;
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.always,
                ),
                TextFormField(
                  controller: travelTypeController,
                  enableInteractiveSelection: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.addTripTypeLabel,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
                      )),
                  validator: (String? value) {
                    if (!state.isTripTypeValid) {
                      return AppLocalizations.of(context)!.addTripTypeValidator;
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
                      labelText: AppLocalizations.of(context)!.addTripLocation,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: ReusableThemeColor().colorOpposite(context)),
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
                SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.addTripPublic),
                    value: ispublic,
                    onChanged: (bool val) => <void>{
                          setState(() {
                            ispublic = val;
                          }),
                        }),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text(
                    AppLocalizations.of(context)!.addTripDescriptionMessage,
                    style: titleMedium(context),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (isAddTripButtonEnabled(state)) {
                          _onFormSubmitted();
                          navigationService
                              .pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
                        } else {
                          _onTripNameChange();
                          _onTripTypeChange();
                        }
                      },
                      child: Text(addTripAddTripButton()),
                    )),
              ])));
    }));
  }

  void _onTripNameChange() {
    _addTripBloc.add(AddTripNameChange(tripName: tripNameController.text));
  }

  void _onTripTypeChange() {
    _addTripBloc.add(AddTripTypeChanged(travelType: travelTypeController.text));
  }

  void _onFormSubmitted() {
    _addTripBloc.add(AddTripButtonPressed(
        ispublic: ispublic,
        location: locationController.text,
        tripGeoPoint: const GeoPoint(10, 10),
        tripName: tripNameController.text,
        travelType: travelTypeController.text));
  }
}
