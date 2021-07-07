import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/lodging_model.dart';

abstract class LodgingEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingLodgingData extends LodgingEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends LodgingEvent {
  final List<LodgingData> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
