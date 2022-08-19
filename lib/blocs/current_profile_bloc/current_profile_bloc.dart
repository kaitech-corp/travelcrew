import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../repositories/current_user_profile_repository.dart';
import 'current_profile_event.dart';
import 'current_profile_state.dart';

class CurrentProfileBloc extends Bloc<CurrentProfileEvent, CurrentProfileState> {
  final CurrentUserProfileRepository? currentUserProfileRepository;
  StreamSubscription? _subscription;


  CurrentProfileBloc({this.currentUserProfileRepository}) : super(CurrentProfileLoadingState()){
    on<LoadingCurrentProfileData>((event, emit) async{
      _subscription = currentUserProfileRepository?.profile().asBroadcastStream().listen((data) { add(CurrentProfileHasDataEvent(data)); });
    });
    on<CurrentProfileHasDataEvent>((event, emit) async => emit(CurrentProfileHasDataState(event.data)));
  }

  CurrentProfileState get initialState => CurrentProfileLoadingState();

  // @override
  // Stream<CurrentProfileState> mapEventToState(CurrentProfileEvent event) async*{
  //   if(event is LoadingCurrentProfileData){
  //     if(_subscription != null){
  //       await _subscription?.cancel();
  //     }
  //     _subscription = currentUserProfileRepository?.profile().asBroadcastStream().listen((data) { add(CurrentProfileHasDataEvent(data)); });
  //   }
  //   else if(event is CurrentProfileHasDataEvent){
  //     yield CurrentProfileHasDataState(event.data);
  //   }
  // }
  @override
  Future<void> close(){
    _subscription?.cancel();
    currentUserProfileRepository?.dispose();
    return super.close();
  }
}