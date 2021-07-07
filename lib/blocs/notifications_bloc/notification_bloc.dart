
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:travelcrew/repositories/notification_repository.dart';
import 'package:travelcrew/repositories/trip_repository.dart';
import 'notification_state.dart';
import 'notification_event.dart';

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
  Future<Function> close(){
    _subscription?.cancel();
    notificationRepository.dispose();
    return super.close();
  }
}