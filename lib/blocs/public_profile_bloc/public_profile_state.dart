import 'package:equatable/equatable.dart';

import '../../models/public_profile_model/public_profile_model.dart';




abstract class PublicProfileState extends Equatable{
  const PublicProfileState();

  @override
  List<Object> get props => <Object>[];
}
class PublicProfileLoadingState extends PublicProfileState {}
class PublicProfileHasDataState extends PublicProfileState {
  const PublicProfileHasDataState(this.data);
  final UserPublicProfile data;
  @override
  List<Object> get props => <Object>[data];
}
