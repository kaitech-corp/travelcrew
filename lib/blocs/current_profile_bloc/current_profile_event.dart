import 'package:equatable/equatable.dart';
import '../../models/custom_objects.dart';

abstract class CurrentProfileEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
class LoadingCurrentProfileData extends CurrentProfileEvent {
  @override
  List<Object> get props => <Object>[];
}
class CurrentProfileHasDataEvent extends CurrentProfileEvent {

  CurrentProfileHasDataEvent(this.data);
  final UserPublicProfile data;

  @override
  List<Object> get props => <Object>[data];
}
