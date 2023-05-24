import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../blocs/public_profile_bloc/public_profile_event.dart';
import '../../../blocs/public_profile_bloc/public_profile_state.dart';

import '../../models/public_profile_model/public_profile_model.dart';
import '../../repositories/user_profile_repository.dart';



class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {


  PublicProfileBloc({this.profileRepository}) : super(PublicProfileLoadingState());
  final PublicProfileRepository? profileRepository;
  StreamSubscription<Object>? _subscription;

  PublicProfileState get initialState => PublicProfileLoadingState();

  Stream<PublicProfileState> mapEventToState(PublicProfileEvent event) async*{
    if(event is LoadingPublicProfileData){
      if(_subscription != null){
        await _subscription?.cancel();
      }
      _subscription = profileRepository?.profile().asBroadcastStream().listen((UserPublicProfile data) { add(PublicProfileHasDataEvent(data)); });
    }
    else if(event is PublicProfileHasDataEvent){
      yield PublicProfileHasDataState(event.data);
    }
  }
  @override
  Future<void> close(){
    _subscription?.cancel();
    profileRepository?.dispose();
    return super.close();
  }
}
