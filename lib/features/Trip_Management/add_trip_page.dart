import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/add_trip_bloc/add_trip_bloc.dart';
import '../../services/theme/text_styles.dart';
import 'add_trip_form.dart';



/// Add trip page
class AddTripPage extends StatelessWidget {
  const AddTripPage({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Add New Trip',style: headlineSmall(context),)
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocProvider<AddTripBloc>(
              create: (BuildContext context) => AddTripBloc(),
              child: const AddTripForm())),
    );
  }
}
