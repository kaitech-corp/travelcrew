
import 'dart:async';

import 'package:bloc/bloc.dart';

import 'generic_state.dart';
import 'generics_event.dart';

abstract class GenericBlocRepository<T> {
  Stream<List<T>> data();
}
class GenericBloc<M, R extends GenericBlocRepository<M>> extends Bloc<GenericEvent,GenericState> {

  GenericBloc({this.repository}) : super(LoadingState()){
   on<LoadingGenericData>((LoadingGenericData event, Emitter<GenericState> emit) async {
     _subscription = repository?.data().asBroadcastStream().listen((List<M> data) {add(HasDataEvent<dynamic>(data)); });
   });
   on<HasDataEvent<dynamic>>((HasDataEvent<dynamic> event, Emitter<GenericState> emit) async => emit(HasDataState<dynamic>(event.data)));
  }

  final R? repository;

  StreamSubscription<dynamic>? _subscription;

  GenericState get initialState => LoadingState();

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
