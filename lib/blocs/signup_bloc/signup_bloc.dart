import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/validators.dart';
import '../../repositories/user_repository.dart';
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
    on<SignupDisplayNameChanged>(
        (SignupDisplayNameChanged event, Emitter<SignupState> emit) async =>
            emit(state.update(
                isDisplayNameValid: isValidDisplayName(event.displayName))));

    on<SignupFirstNameChanged>(
        (SignupFirstNameChanged event, Emitter<SignupState> emit) async => emit(
            state.update(isFirstNameValid: isValidFirstName(event.firstName))));
    on<SignupLastNameChanged>((SignupLastNameChanged event,
            Emitter<SignupState> emit) async =>
        emit(state.update(isLastNameValid: isValidLastName(event.lastName))));

    on<SignupImageChanged>(
        (SignupImageChanged event, Emitter<SignupState> emit) async =>
            emit(state.update(imageAdded: isValidImagePath(event.urlToImage))));
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
