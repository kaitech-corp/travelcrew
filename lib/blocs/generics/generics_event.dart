import 'package:equatable/equatable.dart';

abstract class GenericEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
class LoadingGenericData extends GenericEvent {
  @override
  List<Object> get props => <Object>[];
}
class HasDataEvent<M> extends GenericEvent {

  HasDataEvent(this.data);
  final List<M> data;

  @override
  List<Object> get props => <Object>[data];
}
