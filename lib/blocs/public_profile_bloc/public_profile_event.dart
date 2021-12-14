import 'package:equatable/equatable.dart';
import '../../../models/custom_objects.dart';

abstract class PublicProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingPublicProfileData extends PublicProfileEvent {
  @override
  List<Object> get props => [];
}
class PublicProfileHasDataEvent extends PublicProfileEvent {
  final UserPublicProfile data;

  PublicProfileHasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
