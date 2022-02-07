import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories_v1/user_repository.dart';
import 'apple_login_event.dart';
import 'apple_login_state.dart';



class AppleLoginBloc extends Bloc<AppleLoginEvent, AppleLoginState> {
  final UserRepository _userRepository;

  AppleLoginBloc({UserRepository userRepository})
      : _userRepository = userRepository,
        super(AppleLoginState.initial());

  @override
  Stream<AppleLoginState> mapEventToState(AppleLoginEvent event) async* {
    if (event is AppleLoginPressed) {
      yield* _mapAppleLoginPressedToState();
    }
  }

  Stream<AppleLoginState> _mapAppleLoginPressedToState() async* {
    yield AppleLoginState.loading();
    try {
      await _userRepository.signInWithApple();
      yield AppleLoginState.success();
    } catch (_) {
      yield AppleLoginState.failure();
    }
  }

}