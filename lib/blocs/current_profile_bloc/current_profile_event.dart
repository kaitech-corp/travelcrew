import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/custom_objects.dart';

abstract class CurrentProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingCurrentProfileData extends CurrentProfileEvent {
  @override
  List<Object> get props => [];
}
class CurrentProfileHasDataEvent extends CurrentProfileEvent {
  final UserPublicProfile data;

  CurrentProfileHasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
