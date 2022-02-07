
import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_event.dart';
import '../../../blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_state.dart';
import '../../../repositories_v1/trip_repositories/past_trip_repository.dart';

class PastCrewTripBloc extends Bloc<TripEvent, TripState> {
  final PastTripRepository tripRepository;
  StreamSubscription _subscription;


  PastCrewTripBloc({this.tripRepository}) : super(TripLoadingState());

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
    return super.close();
  }
}