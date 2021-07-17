import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/split_model.dart';

abstract class SplitEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingSplitData extends SplitEvent {
  @override
  List<Object> get props => [];
}
class HasSplitDataEvent extends SplitEvent {
  final List<SplitObject> data;

  HasSplitDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
