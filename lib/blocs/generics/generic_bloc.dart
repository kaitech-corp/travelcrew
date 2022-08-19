
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:travelcrew/blocs/generics/generics_event.dart';

import 'generic_state.dart';

abstract class GenericBlocRepository<T> {
  Stream<List<T>> data();
}
class GenericBloc<M, R extends GenericBlocRepository<M>> extends Bloc<GenericEvent,GenericState> {

  final R? repository;

  StreamSubscription? _subscription;

  GenericState get initialState => LoadingState();

  GenericBloc({this.repository}) : super(LoadingState()){
   on<LoadingGenericData>((event, emit) async {
     _subscription = repository?.data().asBroadcastStream().listen((data) {add(HasDataEvent(data)); });
   });
   on<HasDataEvent>((event, emit) async => emit(HasDataState(event.data)));
  }




  // @override
  // Stream<GenericState> mapEventToState(GenericEvent event) async*{
  //   if(event is LoadingGenericData){
  //     if(_subscription != null){
  //       await _subscription?.cancel();
  //     }
  //     _subscription = repository?.data().asBroadcastStream().listen((data) {add(HasDataEvent(data)); });
  //   }
  //   else if(event is HasDataEvent<M>){
  //     yield HasDataState<M>(event.data);
  //   }
  // }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

