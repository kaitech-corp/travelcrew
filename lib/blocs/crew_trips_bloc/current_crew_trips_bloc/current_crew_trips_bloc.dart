
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trip_event.dart';
import '../../../blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trip_state.dart';
import '../../../repositories_v1/trip_repositories/current_trip_repository.dart';

class CurrentCrewTripBloc extends Bloc<TripEvent, TripState> {
  final CurrentTripRepository tripRepository;
  StreamSubscription _subscription;


  CurrentCrewTripBloc({this.tripRepository}) : super(TripLoadingState());

  TripState get initialState => TripLoadingState();

  @override
  Stream<TripState> mapEventToState(TripEvent event) async*{
    if(event is LoadingData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = tripRepository.trips().asBroadcastStream().listen((trip) { add(HasDataEvent(trip)); });
    }
    else if(event is HasDataEvent){
      yield TripHasDataState(event.data);
    }
  }
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    // tripRepository.dispose();
    super.close();
  }
}