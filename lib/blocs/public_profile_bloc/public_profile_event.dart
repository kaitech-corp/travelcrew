import 'package:equatable/equatable.dart';

import '../../../models/custom_objects.dart';

abstract class PublicProfileEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
class LoadingPublicProfileData extends PublicProfileEvent {
  @override
  List<Object> get props => <Object>[];
}
class PublicProfileHasDataEvent extends PublicProfileEvent {

  PublicProfileHasDataEvent(this.data);
  final UserPublicProfile data;

  @override
  List<Object> get props => <Object>[data];
}
