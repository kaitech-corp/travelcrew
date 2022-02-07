
import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../repositories_v1/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  StreamSubscription _subscription;


  NotificationBloc({this.notificationRepository}) : super(NotificationLoadingState());

  NotificationState get initialState => NotificationLoadingState();

  @override
  Stream<NotificationState> mapEventToState(NotificationEvent event) async*{
    if(event is LoadingNotificationData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = notificationRepository.notifications().asBroadcastStream().listen((data) { add(HasDataEvent(data)); });
    }
    else if(event is HasDataEvent){
      yield NotificationHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}