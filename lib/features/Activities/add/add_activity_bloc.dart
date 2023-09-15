import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activity_model/activity_model.dart';

// Define the events
abstract class ActivityEvent {}

class AddActivityEvent extends ActivityEvent {

  AddActivityEvent(this.activity);
  final ActivityModel activity;
}

// Define the state
abstract class ActivityState {}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivitySuccess extends ActivityState {}

class ActivityError extends ActivityState {

  ActivityError(this.errorMessage);
  final String errorMessage;
}

// Define the BLoC class
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc() : super(ActivityInitial());

  Stream<ActivityState> mapEventToState(ActivityEvent event) async* {
    if (event is AddActivityEvent) {
      yield ActivityLoading();
      try {
        // Perform the activity addition logic here
        // For example, you can use Firestore to add the activity document
        // and handle any errors that occur

        // Assuming the activity addition is successful
        yield ActivitySuccess();
      } catch (e) {
        yield ActivityError('Failed to add activity: $e');
      }
    }
  }
}