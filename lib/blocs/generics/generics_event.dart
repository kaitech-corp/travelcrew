import 'package:equatable/equatable.dart';

abstract class GenericEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingGenericData extends GenericEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent<M> extends GenericEvent {
  final List<M> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}