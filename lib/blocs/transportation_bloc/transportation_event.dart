import 'package:equatable/equatable.dart';
import '../../../models/transportation_model.dart';

abstract class TransportationEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingTransportationData extends TransportationEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends TransportationEvent {
  final List<TransportationData> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
