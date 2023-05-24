import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



import '../../../../repositories/user_repository.dart';
import '../../../../utils/validators.dart';
import 'login_event.dart';
import 'login_state.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({UserRepository? userRepository})
      : _userRepository = userRepository,
        super(LoginState.initial()) {
    on<LoginEmailChange>(
        (LoginEmailChange event, Emitter<LoginState> emit) async =>
            emit(state.update(isEmailValid: isValidEmail(event.email!))));

    on<LoginPasswordChanged>((LoginPasswordChanged event,
            Emitter<LoginState> emit) async =>
        emit(state.update(isPasswordValid: isValidPassword(event.password!))));
    on<LoginWithCredentialsPressed>(
        (LoginWithCredentialsPressed event, Emitter<LoginState> emit) async {
      emit(LoginState.loading());
      try {
        final UserCredential? firebaseUser =
            await _userRepository?.signInWithCredentials(
                email: event.email!, password: event.password!);
        if (firebaseUser!.user!.uid.isNotEmpty) {
          emit(LoginState.success());
        }
        // AuthenticationSuccess(firebaseUser.user);
      } catch (_) {
        emit(LoginState.failure());
      }
    });
    on<LoginWithApplePressed>(
        (LoginWithApplePressed event, Emitter<LoginState> emit) async {
      emit(LoginState.loading());
      try {
        final UserCredential? user = await _userRepository?.signInWithApple();
        if (user!.user!.uid.isNotEmpty) {
          emit(LoginState.success());
        }
      } catch (_) {
        emit(LoginState.failure());
      }
    });
    on<LoginWithGooglePressed>(
        (LoginWithGooglePressed event, Emitter<LoginState> emit) async {
      emit(LoginState.loading());
      try {
        final UserCredential? user = await _userRepository?.signInWithGoogle();
        if (user!.user!.uid.isNotEmpty) {
          emit(LoginState.success());
        }
      } catch (_) {
        emit(LoginState.failure());
      }
    });
  }
  final UserRepository? _userRepository;
}
