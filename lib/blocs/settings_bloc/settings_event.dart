import 'package:equatable/equatable.dart';

import '../../../models/settings_model.dart';

abstract class UserSettingsEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingUserSettingsData extends UserSettingsEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends UserSettingsEvent {
  final UserNotificationSettingsData data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
