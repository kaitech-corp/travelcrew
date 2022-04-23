import 'package:equatable/equatable.dart';
/// Generic State for an activity.
abstract class GenericState extends Equatable{
  GenericState();

  @override
  List<Object> get props => [];
}
/// State for an activity that is loading.
class LoadingState extends GenericState {}

/// State for an activity that has data available.
class HasDataState<M> extends GenericState {
  final List<M> data;

  HasDataState(this.data);

  @override
  List<Object> get props => [data];

}