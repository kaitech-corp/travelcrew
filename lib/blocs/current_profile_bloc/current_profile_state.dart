import 'package:equatable/equatable.dart';
import '../../models/custom_objects.dart';


abstract class CurrentProfileState extends Equatable{
  const CurrentProfileState();

  @override
  List<Object> get props => <Object>[];
}
class CurrentProfileLoadingState extends CurrentProfileState {}
class CurrentProfileHasDataState extends CurrentProfileState {
  const CurrentProfileHasDataState(this.data);
  final UserPublicProfile data;
  @override
  List<Object> get props => <Object>[data];
}
