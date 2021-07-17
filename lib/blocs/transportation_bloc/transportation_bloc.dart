
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_event.dart';
import 'package:travelcrew/blocs/transportation_bloc/transportation_state.dart';
import 'package:travelcrew/repositories/transportation_repository.dart';


class TransportationBloc extends Bloc<TransportationEvent, TransportationState> {
  final TransportationRepository transportationRepository;
  StreamSubscription _subscription;


  TransportationBloc({this.transportationRepository}) : super(TransportationLoadingState());

  TransportationState get initialState => TransportationLoadingState();

  @override
  Stream<TransportationState> mapEventToState(TransportationEvent event) async*{
    if(event is LoadingTransportationData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = transportationRepository.transportation().asBroadcastStream().listen((data) { add(HasDataEvent(data)); });
    }
    else if(event is HasDataEvent){
      yield TransportationHasDataState(event.data);
    }
  }
  @override
  Future<Function> close(){
    _subscription?.cancel();
    transportationRepository.dispose();
    return super.close();
  }
}