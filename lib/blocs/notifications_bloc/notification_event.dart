import 'package:equatable/equatable.dart';
import '../../../models/notification_model.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingNotificationData extends NotificationEvent {
  @override
  List<Object> get props => [];
}
class HasDataEvent extends NotificationEvent {
  final List<NotificationData> data;

  HasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
