import 'package:equatable/equatable.dart';

import '../../../models/notification_model.dart';


abstract class NotificationState extends Equatable{
  NotificationState();

  @override
  List<Object> get props => [];
}
class NotificationLoadingState extends NotificationState {}
class NotificationHasDataState extends NotificationState {
  final List<NotificationData> data;
  NotificationHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
