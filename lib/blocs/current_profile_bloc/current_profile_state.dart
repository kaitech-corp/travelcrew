import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/custom_objects.dart';


abstract class CurrentProfileState extends Equatable{
  CurrentProfileState();

  @override
  List<Object> get props => [];
}
class CurrentProfileLoadingState extends CurrentProfileState {}
class CurrentProfileHasDataState extends CurrentProfileState {
  final UserPublicProfile data;
  CurrentProfileHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
