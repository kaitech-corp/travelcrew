import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'authentication_event.dart';
import 'authentication_state.dart';
import 'user_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(AuthenticationInitial()) {
    // Authentication Logged In
    on<AuthenticationLoggedIn>((AuthenticationLoggedIn event,
        Emitter<AuthenticationState> emit) async {
      final bool isSignedIn = await _userRepository!.isSignedIn();
      if (isSignedIn) {
        try {
          final User? firebaseUser = _userRepository!.getUser();
          if (firebaseUser != null) {
            emit(AuthenticationSuccess(firebaseUser));
          }
        } catch (e) {
          emit(AuthenticationFailure());
        }
      } else {
        emit(AuthenticationFailure());
      }
    });
    // Authentication Logged Out
    on<AuthenticationLoggedOut>((AuthenticationLoggedOut event,
        Emitter<AuthenticationState> emit) async {
      _userRepository!.signOut();
      emit(AuthenticationFailure());
    });
  }
  final UserRepository? _userRepository;
}
