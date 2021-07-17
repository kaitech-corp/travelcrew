import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/transportation_model.dart';

abstract class TransportationState extends Equatable{
  TransportationState();

  @override
  List<Object> get props => [];
}
class TransportationLoadingState extends TransportationState {}
class TransportationHasDataState extends TransportationState {
  final List<TransportationData> data;
  TransportationHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
