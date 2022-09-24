import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/functions/cloud_functions.dart';

class CustomBlocObserver extends BlocObserver {


  @override
  void onChange(BlocBase<dynamic> bloc, Change change) {
    super.onChange(bloc, change);
    // print('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}, $error');
    CloudFunction().logError('Bloc Observer error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    // print('onClose -- ${bloc.runtimeType}');
  }
}
