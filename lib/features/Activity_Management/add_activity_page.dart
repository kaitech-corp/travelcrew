import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/add_trip_bloc/add_trip_bloc.dart';
import '../../services/theme/text_styles.dart';
import 'activity_form.dart';




/// Add trip page
class AddActivityPage extends StatelessWidget {
  const AddActivityPage({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Add Activity',style: headlineSmall(context),)
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocProvider<AddTripBloc>(
              create: (BuildContext context) => AddTripBloc(),
              child: const ActivityForm())),
    );
  }
}
