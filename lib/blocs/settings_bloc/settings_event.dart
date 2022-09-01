import 'package:equatable/equatable.dart';

import '../../../models/settings_model.dart';

abstract class UserSettingsEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
class LoadingUserSettingsData extends UserSettingsEvent {
  @override
  List<Object> get props => <Object>[];
}
class HasDataEvent extends UserSettingsEvent {

  HasDataEvent(this.data);
  final UserNotificationSettingsData data;

  @override
  List<Object> get props => <Object>[data];
}
