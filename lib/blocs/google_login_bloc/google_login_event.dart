import 'package:equatable/equatable.dart';

abstract class GoogleLoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}


class GoogleLoginPressed extends GoogleLoginEvent {

  GoogleLoginPressed();

  @override
  List<Object> get props => [];
}