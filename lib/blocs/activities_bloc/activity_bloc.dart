
import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../repositories_v1/activity_repository.dart';
import 'activity_event.dart';
import 'activity_state.dart';

/// BLoC for activities.
/// Activities can either be loading or have some data available.
///
/// BLoC is a predictable state management library for Dart. See https://bloclibrary.dev
class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository activityRepository;
  StreamSubscription _subscription;


  ActivityBloc({this.activityRepository}) : super(ActivityLoadingState());

  ActivityState get initialState => ActivityLoadingState();


  @override
  Stream<ActivityState> mapEventToState(ActivityEvent event) async*{
    if(event is LoadingActivityData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = activityRepository.activities().asBroadcastStream().listen((activity) {add(HasDataEvent(activity)); });
    }
    else if(event is HasDataEvent){
      yield ActivityHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
