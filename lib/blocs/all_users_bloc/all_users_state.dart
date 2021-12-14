import 'package:equatable/equatable.dart';

import '../../models/custom_objects.dart';

abstract class AllUserState extends Equatable{
  AllUserState();

  @override
  List<Object> get props => [];
}
class AllUserLoadingState extends AllUserState {}
class AllUserHasDataState extends AllUserState {
  final List<UserPublicProfile> data;
  AllUserHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
