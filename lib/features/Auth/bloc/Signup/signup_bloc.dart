import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../utils/validators.dart';
import '../user_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({UserRepository? userRepository})
      : _userRepository = userRepository,
        super(SignupState.initial()) {
    on<SignupEmailChanged>(
        (SignupEmailChanged event, Emitter<SignupState> emit) async =>
            emit(state.update(isEmailValid: isValidEmail(event.email))));

    on<SignupPasswordChanged>((SignupPasswordChanged event,
            Emitter<SignupState> emit) async =>
        emit(state.update(isPasswordValid: isValidPassword(event.password))));
    on<SignupWithApplePressed>(
        (SignupWithApplePressed event, Emitter<SignupState> emit) async {
      emit(SignupState.loading());
      try {
        final UserCredential? user = await _userRepository?.signInWithApple();
        if (user!.user!.uid.isNotEmpty) {
          emit(SignupState.success());
        }
      } catch (_) {
        emit(SignupState.failure());
      }
    });
    on<SignupWithGooglePressed>(
        (SignupWithGooglePressed event, Emitter<SignupState> emit) async {
      emit(SignupState.loading());
      try {
        final UserCredential? user = await _userRepository?.signInWithGoogle();
        if (user!.user!.uid.isNotEmpty) {
          emit(SignupState.success());
        }
      } catch (_) {
        emit(SignupState.failure());
      }
    });
    on<SignupSubmitted>((SignupSubmitted event, Emitter<SignupState> emit) async {
      emit(SignupState.loading());
      try {
        await UserRepository().signUp(
            event.email, event.password, event.firstName, event.lastName, event.displayName, event.urlToImage);
          emit(SignupState.success());
        } catch (_) {
        emit(SignupState.failure());
      }
    });
  }
  final UserRepository? _userRepository;
}
