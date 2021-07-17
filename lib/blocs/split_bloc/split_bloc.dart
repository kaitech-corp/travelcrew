import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:travelcrew/repositories/split_repository.dart';

import 'split_event.dart';
import 'split_state.dart';

class SplitBloc extends Bloc<SplitEvent, SplitState> {
  final SplitRepository splitRepository;
  StreamSubscription _subscription;


  SplitBloc({this.splitRepository}) : super(SplitLoadingState());

  SplitState get initialState => SplitLoadingState();

  @override
  Stream<SplitState> mapEventToState(SplitEvent event) async*{
    if(event is LoadingSplitData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = splitRepository.splitData().asBroadcastStream().listen((activity) {add(HasSplitDataEvent(activity)); });
    }
    else if(event is HasSplitDataEvent){
      yield SplitHasDataState(event.data);
    }
  }
  @override
  Future<Function> close(){
    _subscription?.cancel();
    splitRepository.dispose();
    return super.close();
  }
}