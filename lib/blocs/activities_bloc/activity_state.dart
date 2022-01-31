import 'package:equatable/equatable.dart';

import '../../models/activity_model.dart';

/// State for an activity.
abstract class ActivityState extends Equatable{
  ActivityState();

  @override
  List<Object> get props => [];
}

/// State for an activity that is loading.
class ActivityLoadingState extends ActivityState {}

/// State for an activity that has data available.
class ActivityHasDataState extends ActivityState {
  final List<ActivityData> data;
  ActivityHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
