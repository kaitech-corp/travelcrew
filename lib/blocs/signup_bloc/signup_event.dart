import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => <Object>[];
}

class SignupFirstNameChanged extends SignupEvent {
  SignupFirstNameChanged({required this.firstName});
  final String? firstName;

  @override
  List<Object?> get props => <Object?>[firstName];
}

class SignupLastNameChanged extends SignupEvent {
  SignupLastNameChanged({required this.lastName});
  final String? lastName;

  @override
  List<Object?> get props => <Object?>[lastName];
}

class SignupDisplayNameChanged extends SignupEvent {
  SignupDisplayNameChanged({required this.displayName});
  final String? displayName;

  @override
  List<Object?> get props => <Object?>[displayName];
}

class SignupImageChanged extends SignupEvent {
  SignupImageChanged({required this.urlToImage});
  final File? urlToImage;

  @override
  List<Object?> get props => <Object?>[urlToImage];
}

class SignupEmailChanged extends SignupEvent {
  SignupEmailChanged({required this.email});
  final String email;

  @override
  List<Object> get props => <Object>[email];
}

class SignupPasswordChanged extends SignupEvent {
  SignupPasswordChanged({required this.password});
  final String password;

  @override
  List<Object> get props => <Object>[password];
}

class SignupWithApplePressed extends SignupEvent {
  SignupWithApplePressed();
  @override
  List<Object> get props => <Object>[];
}

class SignupWithGooglePressed extends SignupEvent {
  SignupWithGooglePressed();
    @override
  List<Object> get props => <Object>[];
}

class SignupSubmitted extends SignupEvent {
  SignupSubmitted(
      {this.firstName,
      this.lastName,
      this.displayName,
      this.urlToImage,
      required this.email,
      required this.password});
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final File? urlToImage;

  @override
  List<Object?> get props =>
      <Object?>[email, password, displayName, firstName, lastName, urlToImage];
}
