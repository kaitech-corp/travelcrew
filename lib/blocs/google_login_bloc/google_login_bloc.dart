import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../../blocs/authentication_bloc/authentication_event.dart';
import '../../../repositories/user_repository.dart';
import 'google_login_event.dart';
import 'google_login_state.dart';




class GoogleLoginBloc extends Bloc<GoogleLoginEvent, GoogleLoginState> {
  final UserRepository _userRepository;

  GoogleLoginBloc({UserRepository userRepository})
      : _userRepository = userRepository,
        super(GoogleLoginState.initial());

  @override
  Stream<GoogleLoginState> mapEventToState(GoogleLoginEvent event) async* {
    if (event is GoogleLoginPressed) {
      yield* _mapAppleLoginPressedToState();
    }
  }

  Stream<GoogleLoginState> _mapAppleLoginPressedToState() async* {
    yield GoogleLoginState.loading();
    try {
      await _userRepository.signInWithGoogle();
      AuthenticationBloc().add(AuthenticationStarted());
      yield GoogleLoginState.success();
    } catch (_) {
      yield GoogleLoginState.failure();
    }
  }

}