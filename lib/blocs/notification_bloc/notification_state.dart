import 'package:equatable/equatable.dart';


import '../../models/notification_model/notification_model.dart';


abstract class NotificationState extends Equatable{
  const NotificationState();

  @override
  List<Object> get props => <Object>[];
}
class NotificationLoadingState extends NotificationState {}
class NotificationHasDataState extends NotificationState {
  const NotificationHasDataState(this.data);
  final List<NotificationModel> data;
  @override
  List<Object> get props => <Object>[data];
}
