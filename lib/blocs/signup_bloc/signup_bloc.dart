


import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/validators.dart';
import '../../repositories/user_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {

  SignupBloc({UserRepository? userRepository})
      : _userRepository = userRepository,
        super(SignupState.initial());

  final UserRepository? _userRepository;


  Stream<SignupState> mapEventToState(SignupEvent event) async* {
    if (event is SignupEmailChanged) {
      yield* _mapSignupEmailChangeToState(event.email);
    } else if (event is SignupPasswordChanged) {
      yield* _mapSignupPasswordChangeToState(event.password);
    }else if (event is SignupDisplayNameChanged){
      yield* _mapSignupDisplayNameChangeToState(event.displayName);
    } else if (event is SignupFirstNameChanged){
      yield* _mapSignupFirstNameChangeToState(event.firstName);
    } else if (event is SignupLastNameChanged){
      yield* _mapSignupLastNameChangeToState(event.lastName);
    } else if (event is SignupImageChanged){
      yield* _mapSignupImageChangeToState(event.urlToImage);
    } else if (event is SignupSubmitted) {
      yield* _mapSignupSubmittedToState(
          email: event.email,
          password: event.password,
          displayName: event.displayName,
          firstName: event.firstName,
          lastName: event.lastName,
          urlToImage: event.urlToImage
      );
    }
  }

  Stream<SignupState> _mapSignupEmailChangeToState(String email) async* {
    yield state.update(isEmailValid: isValidEmail(email));
  }

  Stream<SignupState> _mapSignupPasswordChangeToState(String password) async* {
    yield state.update(isPasswordValid: isValidPassword(password));
  }
  Stream<SignupState> _mapSignupImageChangeToState(File? urlToImage) async* {
    yield state.update(imageAdded: true);
  }
  Stream<SignupState> _mapSignupDisplayNameChangeToState(String? displayName) async* {
    yield state.update(isDisplayNameValid: true);
  }
  Stream<SignupState> _mapSignupFirstNameChangeToState(String? firstName) async* {
    yield state.update(isFirstNameValid: true);
  }
  Stream<SignupState> _mapSignupLastNameChangeToState(String? lastName) async* {
    yield state.update(isLastNameValid: true);
  }

  Stream<SignupState> _mapSignupSubmittedToState({
    required String email,
    required String password,
    String? displayName,
    String? firstName,
    String? lastName,
    File? urlToImage}) async* {
    yield SignupState.loading();
    try {
      await UserRepository().signUp(email, password, firstName, lastName, displayName, urlToImage);
      yield SignupState.success();
    } catch (error) {
      // TODO(Randy): log error.
      yield SignupState.failure();
    }
  }
}
