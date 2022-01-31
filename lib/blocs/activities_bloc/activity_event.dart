import 'package:equatable/equatable.dart';

import '../../models/activity_model.dart';

/// Any event an actitivity can trigger.
abstract class ActivityEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event for when an activity is loading.
class LoadingActivityData extends ActivityEvent {
  @override
  List<Object> get props => [];
}

/// Event for when an activity has data.
class HasDataEvent extends ActivityEvent {
  final List<ActivityData> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
