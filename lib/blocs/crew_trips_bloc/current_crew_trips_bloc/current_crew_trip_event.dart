import 'package:equatable/equatable.dart';

import '../../../models/trip_model.dart';

abstract class TripEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingData extends TripEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends TripEvent {
  final List<Trip> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
