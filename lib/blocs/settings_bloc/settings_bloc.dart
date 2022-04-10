
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/settings_bloc/setting_state.dart';
import '../../../blocs/settings_bloc/settings_event.dart';
import '../../repositories/user_settings_repository.dart';


class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  final UserSettingsRepository? userSettingsRepository;
  StreamSubscription? _subscription;


  UserSettingsBloc({this.userSettingsRepository}) : super(UserSettingsLoadingState());

  UserSettingsState get initialState => UserSettingsLoadingState();


  @override
  Stream<UserSettingsState> mapEventToState(UserSettingsEvent event) async*{
    if(event is LoadingUserSettingsData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = userSettingsRepository
          ?.settingsData()
          .asBroadcastStream()
          .listen((activity) {add(HasDataEvent(activity)); });
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