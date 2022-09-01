import 'package:equatable/equatable.dart';
/// Generic State for an activity.
abstract class GenericState extends Equatable{
  const GenericState();

  @override
  List<Object> get props => <Object>[];
}
/// State for an activity that is loading.
class LoadingState extends GenericState {}

/// State for an activity that has data available.
class HasDataState<M> extends GenericState {

  const HasDataState(this.data);
  final List<M> data;

  @override
  List<Object> get props => <Object>[data];

}
