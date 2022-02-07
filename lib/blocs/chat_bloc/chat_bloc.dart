
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../repositories_v1/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';


class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription _subscription;


  ChatBloc({this.chatRepository}) : super(ChatLoadingState());

  ChatState get initialState => ChatLoadingState();

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async*{
    if(event is LoadingChatData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = chatRepository.chats().asBroadcastStream().listen((chat) { add(ChatHasDataEvent(chat)); });
    }
    else if(event is ChatHasDataEvent){
      yield ChatHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    // chatRepository.dispose();
    super.close();
  }
}