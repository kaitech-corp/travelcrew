import 'package:equatable/equatable.dart';

import '../../models/custom_objects.dart';

abstract class AllUserEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingAllUserData extends AllUserEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends AllUserEvent {
  final List<UserPublicProfile> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
