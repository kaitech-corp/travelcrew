import 'package:equatable/equatable.dart';

import '../../../models/settings_model.dart';

abstract class UserSettingsState extends Equatable{
  const UserSettingsState();

  @override
  List<Object> get props => <Object>[];
}
class UserSettingsLoadingState extends UserSettingsState {}
class UserSettingsHasDataState extends UserSettingsState {
  const UserSettingsHasDataState(this.data);
  final UserNotificationSettingsData data;
  @override
  List<Object> get props => <Object>[data];
}
