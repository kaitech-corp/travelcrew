

import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CompleteProfileEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CompleteProfileFirstNameChanged extends CompleteProfileEvent {
  final String firstName;

  CompleteProfileFirstNameChanged({this.firstName});

  @override
  List<Object> get props => [firstName];
}
class CompleteProfileLastNameChanged extends CompleteProfileEvent {
  final String lastName;

  CompleteProfileLastNameChanged({this.lastName});

  @override
  List<Object> get props => [lastName];
}
class CompleteProfileDisplayNameChanged extends CompleteProfileEvent {
  final String displayName;

  CompleteProfileDisplayNameChanged({this.displayName});

  @override
  List<Object> get props => [displayName];
}

class CompleteProfileImageChanged extends CompleteProfileEvent {
  final File urlToImage;

  CompleteProfileImageChanged({this.urlToImage});

  @override
  List<Object> get props => [urlToImage];
}

class CompleteProfileSubmitted extends CompleteProfileEvent {
  final String firstName;
  final String lastName;
  final String displayName;
  final File urlToImage;

  CompleteProfileSubmitted({this.firstName, this.lastName, this.displayName, this.urlToImage,});

  @override
  List<Object> get props => [ displayName, firstName, lastName, urlToImage];
}