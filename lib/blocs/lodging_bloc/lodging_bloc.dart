
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/lodging_bloc/lodging_event.dart';
import '../../../blocs/lodging_bloc/lodging_state.dart';
import '../../repositories_v1/lodging_repository.dart';


class LodgingBloc extends Bloc<LodgingEvent, LodgingState> {
  final LodgingRepository lodgingRepository;
  StreamSubscription _subscription;


  LodgingBloc({this.lodgingRepository}) : super(LodgingLoadingState());

  LodgingState get initialState => LodgingLoadingState();

  @override
  Stream<LodgingState> mapEventToState(LodgingEvent event) async*{
    if(event is LoadingLodgingData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = lodgingRepository.lodging().asBroadcastStream().listen((trip) { add(HasDataEvent(trip)); });
    }
    else if(event is HasDataEvent){
      yield LodgingHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}