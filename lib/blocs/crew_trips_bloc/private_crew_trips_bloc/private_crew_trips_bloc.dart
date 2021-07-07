
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:travelcrew/repositories/trip_repository.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trip_event.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trip_state.dart';

class PrivateTripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository tripRepository;
  StreamSubscription _subscription;


  PrivateTripBloc({this.tripRepository}) : super(TripLoadingState());

  TripState get initialState => TripLoadingState();

  @override
  Stream<TripState> mapEventToState(TripEvent event) async*{
    if(event is LoadingData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = tripRepository.tripsPrivate().asBroadcastStream().listen((trip) { add(HasDataEvent(trip)); });
    }
    else if(event is HasDataEvent){
      yield TripHasDataState(event.data);
    }
  }
  @override
  Future<Function> close(){
    _subscription?.cancel();
    tripRepository.dispose();
    return super.close();
  }
}