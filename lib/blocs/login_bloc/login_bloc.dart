import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/validators.dart';
import '../../repositories/user_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository? _userRepository;

  LoginBloc({UserRepository? userRepository})
      : _userRepository = userRepository,
        super(LoginState.initial()) {
    on<LoginEmailChange>((event, emit) async =>
        state.update(isEmailValid: Validators.isValidEmail(event.email!)));
    on<LoginPasswordChanged>((event, emit) async => state.update(
        isPasswordValid: Validators.isValidPassword(event.password!)));
    on<LoginWithCredentialsPressed>((event, emit) async {
      emit(LoginState.loading());
      try {
        final firebaseUser = await _userRepository?.signInWithCredentials(
            email: event.email!, password: event.password!);
        emit(LoginState.success());
        // AuthenticationSuccess(firebaseUser.user);
      } catch (_) {
        emit(LoginState.failure());
      }
    });
    on<LoginWithApplePressed>((event, emit) async {
      emit(LoginState.loading());
      try {
        UserCredential? user = await _userRepository?.signInWithApple();
        if (user!.user!.uid.isNotEmpty) {
          emit(LoginState.success());
        }
      } catch (_) {
        emit(LoginState.failure());
      }
    });
    on<LoginWithGooglePressed>((event, emit) async {
      emit(LoginState.loading());
      try {
        UserCredential? user = await _userRepository?.signInWithGoogle();
        if (user!.user!.uid.isNotEmpty) {
          emit(LoginState.success());
        }
      } catch (_) {
        emit(LoginState.failure());
      }
    });
  }
}
