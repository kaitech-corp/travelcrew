import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../blocs/add_trip_bloc/add_trip_bloc.dart';
import '../../models/custom_objects.dart';
import '../../models/trip_model.dart';
import '../../services/analytics_service.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/image_picker_cropper/image_picker_cropper.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/calendar_widget.dart';
import '../alerts/alert_dialogs.dart';
import 'add_trip_form.dart';
import 'google_autocomplete.dart';

GoogleData? googleData;

/// Add trip page
class AddTripPage extends StatelessWidget {
  const AddTripPage({Key? key, this.addedLocation}) : super(key: key);
  //When using google places this object will pass on the location.
  final String? addedLocation;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocProvider<AddTripBloc>(
            create: (BuildContext context) => AddTripBloc(),
            child: AddTripForm(addedLocation: addedLocation,)));
  }
}
