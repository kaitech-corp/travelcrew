import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => <Object>[];
}

class LoginEmailChange extends LoginEvent {

  LoginEmailChange({this.email});
  final String? email;

  @override
  List<Object> get props => <Object>[email!];
}

class LoginPasswordChanged extends LoginEvent {

  LoginPasswordChanged({required this.password});
  final String? password;

  @override
  List<Object> get props => <Object>[password!];
}

class LoginWithCredentialsPressed extends LoginEvent {

  LoginWithCredentialsPressed({this.email, this.password});
  final String? email;
  final String? password;

  @override
  List<Object> get props => <Object>[email!, password!];
}

class LoginWithApplePressed extends LoginEvent {


  LoginWithApplePressed();

  @override
  List<Object> get props => <Object>[];
}

class LoginWithGooglePressed extends LoginEvent {

  LoginWithGooglePressed();

  @override
  List<Object> get props => <Object>[];
}
