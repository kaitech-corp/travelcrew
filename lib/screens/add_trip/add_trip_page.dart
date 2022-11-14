import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/add_trip_bloc/add_trip_bloc.dart';
import '../../models/custom_objects.dart';
import 'add_trip_form.dart';

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
