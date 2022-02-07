
import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../repositories_v1/transportation_repository.dart';
import '../../../blocs/transportation_bloc/transportation_event.dart';
import '../../../blocs/transportation_bloc/transportation_state.dart';


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
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}