import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/custom_objects.dart';


abstract class PublicProfileState extends Equatable{
  PublicProfileState();

  @override
  List<Object> get props => [];
}
class PublicProfileLoadingState extends PublicProfileState {}
class PublicProfileHasDataState extends PublicProfileState {
  final UserPublicProfile data;
  PublicProfileHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
