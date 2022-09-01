

import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class CompleteProfileEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

class CompleteProfileFirstNameChanged extends CompleteProfileEvent {

  CompleteProfileFirstNameChanged({required this.firstName});
  final String firstName;

  @override
  List<Object> get props => <Object>[firstName];
}
class CompleteProfileLastNameChanged extends CompleteProfileEvent {

  CompleteProfileLastNameChanged({this.lastName});
  final String? lastName;

  @override
  List<Object> get props => <Object>[lastName!];
}
class CompleteProfileDisplayNameChanged extends CompleteProfileEvent {

  CompleteProfileDisplayNameChanged({this.displayName});
  final String? displayName;

  @override
  List<Object> get props => <Object>[displayName!];
}

class CompleteProfileImageChanged extends CompleteProfileEvent {

  CompleteProfileImageChanged({this.urlToImage});
  final File? urlToImage;

  @override
  List<Object> get props => <Object>[urlToImage!];
}

class CompleteProfileSubmitted extends CompleteProfileEvent {

  CompleteProfileSubmitted({this.firstName, this.lastName, this.displayName, this.urlToImage,});
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final File? urlToImage;

  @override
  List<Object> get props => <Object>[displayName!, firstName!, lastName!, urlToImage!];
}
