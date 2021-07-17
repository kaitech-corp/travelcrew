import 'package:equatable/equatable.dart';
import 'package:travelcrew/models/chat_model.dart';



abstract class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class LoadingChatData extends ChatEvent {
  @override
  List<Object> get props => [];
}
class ChatHasDataEvent extends ChatEvent {
  final List<ChatData> data;

  ChatHasDataEvent(this.data);

  @override
  List<Object> get props => [data];
}
