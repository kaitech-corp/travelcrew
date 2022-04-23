import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'complete_profile_event.dart';
import 'complete_profile_state.dart';


class CompleteProfileBloc extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  final UserRepository _userRepository;

  CompleteProfileBloc({UserRepository userRepository})
      : _userRepository = userRepository,
        super(CompleteProfileState.initial());

  @override
  Stream<CompleteProfileState> mapEventToState(CompleteProfileEvent event) async* {
    if (event is CompleteProfileDisplayNameChanged){
      yield* _mapCompleteProfileDisplayNameChangeToState(event.displayName);
    } else if (event is CompleteProfileFirstNameChanged){
      yield* _mapCompleteProfileFirstNameChangeToState(event.firstName);
    } else if (event is CompleteProfileLastNameChanged){
      yield* _mapCompleteProfileLastNameChangeToState(event.lastName);
    } else if (event is CompleteProfileImageChanged){
      yield* _mapCompleteProfileImageChangeToState(event.urlToImage);
    } else if (event is CompleteProfileSubmitted) {
      yield* _mapCompleteProfileSubmittedToState(
          displayName: event.displayName,
          firstName: event.firstName,
          lastName: event.lastName,
          urlToImage: event.urlToImage
      );
    }
  }

  Stream<CompleteProfileState> _mapCompleteProfileImageChangeToState(File urlToImage) async* {
    yield state.update(imageAdded: true);
  }
  Stream<CompleteProfileState> _mapCompleteProfileDisplayNameChangeToState(String displayName) async* {
    yield state.update(isDisplayNameValid: true);
  }
  Stream<CompleteProfileState> _mapCompleteProfileFirstNameChangeToState(String firstName) async* {
    yield state.update(isFirstNameValid: true);
  }
  Stream<CompleteProfileState> _mapCompleteProfileLastNameChangeToState(String lastName) async* {
    yield state.update(isLastNameValid: true);
  }

  Stream<CompleteProfileState> _mapCompleteProfileSubmittedToState({
    String displayName,
    String firstName,
    String lastName,
    File urlToImage}) async* {
    yield CompleteProfileState.loading();
    try {
      await _userRepository.updateUserPublicProfile(firstName, lastName, displayName, urlToImage);
      yield CompleteProfileState.success();
    } catch (error) {
      print(error);
      yield CompleteProfileState.failure();
    }
  }
}