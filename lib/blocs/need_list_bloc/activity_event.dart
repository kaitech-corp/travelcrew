import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/activity_model.dart';

abstract class ActivityEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingActivityData extends ActivityEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends ActivityEvent {
  final List<ActivityData> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
