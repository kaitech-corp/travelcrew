import 'package:equatable/equatable.dart';

import '../../models/activity_model.dart';

abstract class ActivityState extends Equatable{
  ActivityState();

  @override
  List<Object> get props => [];
}
class ActivityLoadingState extends ActivityState {}
class ActivityHasDataState extends ActivityState {
  final List<ActivityData> data;
  ActivityHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
