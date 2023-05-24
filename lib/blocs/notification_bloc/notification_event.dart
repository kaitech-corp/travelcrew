import 'package:equatable/equatable.dart';

import '../../models/notification_model/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}
class LoadingNotificationData extends NotificationEvent {
  @override
  List<Object> get props => <Object>[];
}
class HasDataEvent extends NotificationEvent {

  HasDataEvent(this.data);
  final List<NotificationModel> data;

  @override
  List<Object> get props => <Object>[data];
}
