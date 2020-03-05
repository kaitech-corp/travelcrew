import 'package:get_it/get_it.dart';
import 'local_authentication.dart';

GetIt locator;

void setupLocator() {
  locator.registerLazySingleton(() => LocalAuthenticationService());
}