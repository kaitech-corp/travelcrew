import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/validators.dart';
import '../../repositories/user_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository? _userRepository;

  LoginBloc({UserRepository? userRepository})
      : _userRepository = userRepository,
        super(LoginState.initial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginEmailChange) {
      yield* _mapLoginEmailChangeToState(event.email);
    } else if (event is LoginPasswordChanged) {
      yield* _mapLoginPasswordChangeToState(event.password);
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
          email: event.email, password: event.password);
    } else if (event is LoginWithApplePressed) {
      yield* _mapLoginWithApplePressedToState();
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    }
  }

  Stream<LoginState> _mapLoginEmailChangeToState(String? email) async* {
    yield state.update(isEmailValid: Validators.isValidEmail(email!));
  }

  Stream<LoginState> _mapLoginPasswordChangeToState(String? password) async* {
    yield state.update(isPasswordValid: Validators.isValidPassword(password!));
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState(
      {String? email, String? password}) async* {
    yield LoginState.loading();
    try {
      await _userRepository?.signInWithCredentials(email:email!, password: password!);
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithApplePressedToState() async* {
    yield LoginState.loading();
    try {
      await _userRepository?.signInWithApple();
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    yield LoginState.loading();
    try {
      await _userRepository?.signInWithGoogle();
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }

}