import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository? notificationRepository;
  StreamSubscription? _subscription;

  NotificationState get initialState => NotificationLoadingState();

  NotificationBloc({this.notificationRepository})
      : super(NotificationLoadingState()) {
    on<LoadingNotificationData>((event, emit) async {
      _subscription = notificationRepository
          ?.notifications()
          .asBroadcastStream()
          .listen((data) {
        add(HasDataEvent(data));
      });
    });
    on<HasDataEvent>(
        (event, emit) async => emit(NotificationHasDataState(event.data)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
