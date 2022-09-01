import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {

  AuthenticationBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(AuthenticationInitial()) {
    // Authentication Logged In
    on<AuthenticationLoggedIn>((AuthenticationLoggedIn event, Emitter<AuthenticationState> emit) async {
      final bool isSignedIn = await _userRepository!.isSignedIn();
      if (isSignedIn) {
        try {
          final User? firebaseUser = await _userRepository!.user.first;
          emit(AuthenticationSuccess(firebaseUser));
        } catch (e) {
          emit(AuthenticationFailure());
        }
      } else {
        emit(AuthenticationFailure());
      }
    });
    // Authentication Logged Out
    on<AuthenticationLoggedOut>(
        (AuthenticationLoggedOut event, Emitter<AuthenticationState> emit) async => emit(AuthenticationFailure()));
        // (event, emit) async {
        //   _userRepository!.signOut();
        //   emit(AuthenticationFailure());
        // });
    }
  final UserRepository? _userRepository;
}
