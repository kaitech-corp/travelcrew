import 'package:equatable/equatable.dart';

import '../../models/trip_model.dart';

abstract class TripState extends Equatable{
  TripState();

  @override
  List<Object> get props => [];
}
class TripLoadingState extends TripState {}
class TripHasDataState extends TripState {
  final List<Trip> data;
  TripHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
