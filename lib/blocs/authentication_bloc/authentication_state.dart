import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {

  const AuthenticationSuccess(this.firebaseUser);
  final auth.User? firebaseUser;

  @override
  List<Object?> get props => <Object?>[firebaseUser];
}

class AuthenticationFailure extends AuthenticationState {}
