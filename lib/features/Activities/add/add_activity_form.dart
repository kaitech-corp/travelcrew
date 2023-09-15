import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activity_model/activity_model.dart';
import 'add_activity_bloc.dart';

class AddActivityForm extends StatefulWidget {
  const AddActivityForm({super.key});

  @override
  _AddActivityFormState createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ActivityModel _activity;

  @override
  void initState() {
    super.initState();
    // _activity = ActivityModel(); // Initialize the activity object
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActivityBloc, ActivityState>(
      listener: (BuildContext context, ActivityState state) {
        if (state is ActivitySuccess) {
          // Handle success state, e.g., show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity added successfully')),
          );
          // Clear the form
          _formKey.currentState?.reset();
        } else if (state is ActivityError) {
          // Handle error state, e.g., show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      builder: (BuildContext context, ActivityState state) {
        if (state is ActivityLoading) {
          // Handle loading state, e.g., show a loading indicator
          return const CircularProgressIndicator();
        }
        // Build the form
        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Start Time'),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the start time';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  // _activity.startTime = value ?? '';
                },
              ),
              // Add more form fields for other activity properties
              // such as end time, comment, location, etc.
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    _formKey.currentState?.save();
                    // Dispatch the event to add the activity
                    context.read<ActivityBloc>().add(
                          AddActivityEvent(_activity),
                        );
                  }
                },
                child: const Text('Add Activity'),
              ),
            ],
          ),
        );
      },
    );
  }
}
