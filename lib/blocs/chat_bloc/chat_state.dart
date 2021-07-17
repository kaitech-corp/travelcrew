import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/chat_model.dart';

abstract class ChatState extends Equatable{
  ChatState();

  @override
  List<Object> get props => [];
}
class ChatLoadingState extends ChatState {}
class ChatHasDataState extends ChatState {
  final List<ChatData> data;
  ChatHasDataState(this.data);
  @override
  List<Object> get props => [data];
}
