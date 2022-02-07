import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../repositories_v1/trip_ad_repository.dart';
import 'trip_ad_event.dart';
import 'trip_ad_state.dart';



class TripAdBloc extends Bloc<TripAdEvent, TripAdState> {
  final TripAdRepository tripAdRepository;
  StreamSubscription _subscription;


  TripAdBloc({this.tripAdRepository}) : super(TripAdLoadingState());

  TripAdState get initialState => TripAdLoadingState();

  @override
  Stream<TripAdState> mapEventToState(TripAdEvent event) async*{
    if(event is LoadingTripAdData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = tripAdRepository.tripAds().asBroadcastStream().listen((data) { add(HasDataEvent(data)); });
    }
    else if(event is HasDataEvent){
      yield TripAdHasDataState(event.data);
    }
  }
  @override
  Future<Function> close(){
    _subscription?.cancel();
    tripAdRepository.dispose();
    return super.close();
  }
}