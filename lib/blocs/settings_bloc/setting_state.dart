import 'package:equatable/equatable.dart';
import '../../../models/settings_model.dart';

abstract class UserSettingsState extends Equatable{
  UserSettingsState();

  @override
  List<Object> get props => [];
}
class UserSettingsLoadingState extends UserSettingsState {}
class UserSettingsHasDataState extends UserSettingsState {
  final UserNotificationSettingsData data;
  UserSettingsHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
