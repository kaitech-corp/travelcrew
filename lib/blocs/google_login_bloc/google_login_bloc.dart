import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/repositories/user_repository.dart';
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
      await UserRepository().signInWithGoogle();
      yield GoogleLoginState.success();
    } catch (_) {
      yield GoogleLoginState.failure();
    }
  }

}