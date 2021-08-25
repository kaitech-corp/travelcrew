import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class CustomBlocObserver extends BlocObserver {

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // print(transition);
  }

@override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    print(error);
    CloudFunction().logError('Bloc Observer error: $error');
  }
}