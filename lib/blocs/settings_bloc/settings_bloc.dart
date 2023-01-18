
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/settings_bloc/setting_state.dart';
import '../../../blocs/settings_bloc/settings_event.dart';
import '../../models/settings_model.dart';
import '../../repositories/user_settings_repository.dart';


class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {


  UserSettingsBloc({this.userSettingsRepository}) : super(UserSettingsLoadingState());
  final UserSettingsRepository? userSettingsRepository;
  StreamSubscription<Object>? _subscription;

  UserSettingsState get initialState => UserSettingsLoadingState();


  Stream<UserSettingsState> mapEventToState(UserSettingsEvent event) async*{
    if(event is LoadingUserSettingsData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = userSettingsRepository
          ?.settingsData()
          .asBroadcastStream()
          .listen((UserNotificationSettingsData activity) {add(HasDataEvent(activity)); });
    }
    else if(event is HasDataEvent){
      yield UserSettingsHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
