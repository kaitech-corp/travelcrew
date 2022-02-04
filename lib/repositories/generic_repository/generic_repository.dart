import 'dart:async';
import 'package:travelcrew/repositories/trip_repositories/current_trip_repository.dart';
import '../all_users_repository.dart';


/// Generic Interface Firebase collection.
/// Relies on a remote NoSQL document-oriented database.

class GenericRepository<M> {

  final repository = repoList[M.toString()];

  final StreamController<List<M>> loadedData = StreamController<List<M>>.broadcast();

  void dispose() {
    loadedData.close();
  }

  void refresh() {
    // Retrieve data
    Stream<List<M>> data = repository as Stream<List<M>>;
    loadedData.addStream(data);
  }

  Stream<List<M>> data() => loadedData.stream;
}

var repoList = {
  'UserPublicProfile': allUsersFunction(),
  'Trip': currentTripsFunction(),
};