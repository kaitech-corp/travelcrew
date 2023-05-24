import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../models/notification_model/notification_model.dart';
import '../../repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {

  NotificationBloc({this.notificationRepository})
      : super(NotificationLoadingState()) {
    on<LoadingNotificationData>((LoadingNotificationData event, Emitter<NotificationState> emit) async {
      _subscription = notificationRepository
          ?.notifications()
          .asBroadcastStream()
          .listen((List<NotificationModel> data) {
        add(HasDataEvent(data));
      });
    });
    on<HasDataEvent>(
        (HasDataEvent event, Emitter<NotificationState> emit) async => emit(NotificationHasDataState(event.data)));
  }
  final NotificationRepository? notificationRepository;
  StreamSubscription<Object>? _subscription;

  NotificationState get initialState => NotificationLoadingState();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
