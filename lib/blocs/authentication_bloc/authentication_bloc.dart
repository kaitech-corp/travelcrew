import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository? _userRepository;

  AuthenticationBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(AuthenticationInitial()) {
    // Authentication Logged In
    on<AuthenticationLoggedIn>((event, emit) async {
      final isSignedIn = await _userRepository!.isSignedIn();
      if (isSignedIn) {
        try {
          final firebaseUser = await _userRepository!.user.first;
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
        (event, emit) async => emit(AuthenticationFailure()));
        // (event, emit) async {
        //   _userRepository!.signOut();
        //   emit(AuthenticationFailure());
        // });
    }
}
