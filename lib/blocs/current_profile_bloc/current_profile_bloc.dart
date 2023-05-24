import 'dart:async';

import 'package:bloc/bloc.dart';


import '../../models/public_profile_model/public_profile_model.dart';
import '../../repositories/current_user_profile_repository.dart';
import 'current_profile_event.dart';
import 'current_profile_state.dart';

class CurrentProfileBloc
    extends Bloc<CurrentProfileEvent, CurrentProfileState> {
  CurrentProfileBloc({this.currentUserProfileRepository})
      : super(CurrentProfileLoadingState()) {
    on<LoadingCurrentProfileData>((LoadingCurrentProfileData event,
        Emitter<CurrentProfileState> emit) async {
      _subscription = currentUserProfileRepository
          ?.profile()
          .asBroadcastStream()
          .listen((UserPublicProfile data) {
        add(CurrentProfileHasDataEvent(data));
      });
    });
    on<CurrentProfileHasDataEvent>((CurrentProfileHasDataEvent event,
            Emitter<CurrentProfileState> emit) async =>
        emit(CurrentProfileHasDataState(event.data)));
  }
  final CurrentUserProfileRepository? currentUserProfileRepository;
  StreamSubscription<dynamic>? _subscription;

  CurrentProfileState get initialState => CurrentProfileLoadingState();

  @override
  Future<void> close() {
    _subscription?.cancel();
    currentUserProfileRepository?.dispose();
    return super.close();
  }
}
