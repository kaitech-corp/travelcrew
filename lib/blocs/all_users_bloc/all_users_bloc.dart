
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../repositories_v1/all_users_repository.dart';
import 'all_users_event.dart';
import 'all_users_state.dart';



class AllUserBloc extends Bloc<AllUserEvent, AllUserState> {
  final AllUserRepository allUserRepository;
  StreamSubscription _subscription;


  AllUserBloc({this.allUserRepository}) : super(AllUserLoadingState());

  AllUserState get initialState => AllUserLoadingState();

  @override
  Stream<AllUserState> mapEventToState(AllUserEvent event) async*{
    if(event is LoadingAllUserData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = allUserRepository.users().asBroadcastStream().listen((data) {add(HasDataEvent(data)); });
    }
    else if(event is HasDataEvent){
      yield AllUserHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}