import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/public_profile_bloc/public_profile_event.dart';
import '../../../blocs/public_profile_bloc/public_profile_state.dart';
import '../../repositories/user_profile_repository.dart';



class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final PublicProfileRepository profileRepository;
  StreamSubscription _subscription;


  PublicProfileBloc({this.profileRepository}) : super(PublicProfileLoadingState());

  PublicProfileState get initialState => PublicProfileLoadingState();

  @override
  Stream<PublicProfileState> mapEventToState(PublicProfileEvent event) async*{
    if(event is LoadingPublicProfileData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = profileRepository.profile().asBroadcastStream().listen((data) { add(PublicProfileHasDataEvent(data)); });
    }
    else if(event is PublicProfileHasDataEvent){
      yield PublicProfileHasDataState(event.data);
    }
  }
  @override
  Future<Function> close(){
    _subscription?.cancel();
    profileRepository.dispose();
    return super.close();
  }
}