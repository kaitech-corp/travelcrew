
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:travelcrew/blocs/generics/generics_event.dart';
import 'package:travelcrew/repositories/generic_repository/generic_repository.dart';
import 'generic_state.dart';


class GenericBloc<M> extends Bloc<GenericEvent,GenericState> {

  final GenericRepository<M> repository;

  StreamSubscription _subscription;


  GenericBloc({this.repository}) : super(LoadingState());

  GenericState get initialState => LoadingState();


  @override
  Stream<GenericState> mapEventToState(GenericEvent event) async*{
    if(event is LoadingGenericData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = repository.data().asBroadcastStream().listen((data) {add(HasDataEvent(data)); });
    }
    else if(event is HasDataEvent<M>){
      yield HasDataState<M>(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}