

import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SignupFirstNameChanged extends SignupEvent {
  final String firstName;

  SignupFirstNameChanged({this.firstName});

  @override
  List<Object> get props => [firstName];
}
class SignupLastNameChanged extends SignupEvent {
  final String lastName;

  SignupLastNameChanged({this.lastName});

  @override
  List<Object> get props => [lastName];
}
class SignupDisplayNameChanged extends SignupEvent {
  final String displayName;

  SignupDisplayNameChanged({this.displayName});

  @override
  List<Object> get props => [displayName];
}

class SignupImageChanged extends SignupEvent {
  final File urlToImage;

  SignupImageChanged({this.urlToImage});

  @override
  List<Object> get props => [urlToImage];
}
class SignupEmailChanged extends SignupEvent {
  final String email;

  SignupEmailChanged({this.email});

  @override
  List<Object> get props => [email];
}

class SignupPasswordChanged extends SignupEvent {
  final String password;

  SignupPasswordChanged({this.password});

  @override
  List<Object> get props => [password];
}

class SignupSubmitted extends SignupEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String displayName;
  final File urlToImage;

  SignupSubmitted({this.firstName, this.lastName, this.displayName, this.urlToImage, this.email, this.password});

  @override
  List<Object> get props => [email, password, displayName, firstName, lastName, urlToImage];
}