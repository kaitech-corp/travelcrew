import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/trip_model.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to our 'trips' Firebase collection.
/// It contains all the trips that the users create.
///
/// Relies on a remote NoSQL document-oriented database.
class TripRepository {
  final Query tripCollection = FirebaseFirestore.instance.collection("trips").orderBy('endDateTimeStamp').where('ispublic', isEqualTo: true);


  final _loadedDataCurrentTrips = StreamController<List<Trip>>.broadcast();
  final _loadedDataPastTrips = StreamController<List<Trip>>.broadcast();
  final _loadedDataPrivateTrips = StreamController<List<Trip>>.broadcast();
  final _loadedDataAllTrips = StreamController<List<Trip>>.broadcast();
  final _loadedDataFavoriteTrips = StreamController<List<Trip>>.broadcast();


  void dispose() {
    _loadedDataCurrentTrips.close();
    _loadedDataPastTrips.close();
    _loadedDataPrivateTrips.close();
    _loadedDataAllTrips.close();
    _loadedDataFavoriteTrips.close();
  }

  void refresh() {

    List<Trip> _currentCrewTripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        final now = DateTime.now().toUtc();
        var past = DateTime(now.year, now.month, now.day - 2);
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        List<Trip> crewTrips = trips.where((trip) =>
        trip.endDateTimeStamp.toDate().compareTo(past) == 1).toList();
        return crewTrips;
      } catch (e) {
        CloudFunction().logError('Error retrieving current trip list:  ${e.toString()}');
        return null;
      }
    }

    Stream<List<Trip>> currentCrewTrips = tripCollection.where(
        'accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_currentCrewTripListFromSnapshot);
    _loadedDataCurrentTrips.addStream(currentCrewTrips);


  }
  void refreshPastTrips() {

    List<Trip> _pastCrewTripListFromSnapshot(QuerySnapshot snapshot){

      try {
        final now = DateTime.now().toUtc();
        var past = DateTime(now.year, now.month, now.day - 1);
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        List<Trip> crewTrips = trips.where((trip) =>
        trip.endDateTimeStamp.toDate().compareTo(past) == -1)
            .toList().reversed.toList();
        return crewTrips;
      } catch (e) {
        CloudFunction().logError('Error retrieving past trip list:  ${e.toString()}');
        return null;
      }
    }

    Stream<List<Trip>> pastCrewTrips = tripCollection.where(
        'accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_pastCrewTripListFromSnapshot);
    _loadedDataPastTrips.addStream(pastCrewTrips);


  }

  void refreshPrivateTrips(){

    final Query privateTripCollection = FirebaseFirestore.instance.collection("privateTrips").orderBy('endDateTimeStamp');

    List<Trip> _privateTripListFromSnapshot(QuerySnapshot snapshot){
      try {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList().reversed.toList();
      } catch (e){
        CloudFunction().logError('Error retrieving private trip list:  ${e.toString()}');
        return null;
      }
    }

    Stream<List<Trip>> privateTrips = privateTripCollection.where(
        'accessUsers', arrayContainsAny: [userService.currentUserID])
        .snapshots()
        .map(_privateTripListFromSnapshot);
    _loadedDataPrivateTrips.addStream(privateTrips);

  }
  void refreshAllTrips(){
    // Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        trips.sort((a,b) => a.startDateTimeStamp.compareTo(b.startDateTimeStamp));
        trips = trips.where((trip) =>
          !trip.accessUsers.contains(userService.currentUserID)).toList()
            .where((trip) =>
            trip.endDateTimeStamp.toDate().isAfter(DateTime.now())).toList();
        return trips;
      } catch (e) {
        CloudFunction().logError('Error retrieving all trip list:  ${e.toString()}');
        return null;
      }
    }
    // get trips stream
    Stream<List<Trip>> allTrips = tripCollection.snapshots()
        .map(_tripListFromSnapshot);
    _loadedDataAllTrips.addStream(allTrips);

  }

  void refreshFavoriteTrips(){
    // Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<Trip> trips = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Trip.fromData(data);
        }).toList();
        trips.sort((a,b) => a.startDateTimeStamp.compareTo(b.startDateTimeStamp));

        return trips;
      } catch (e) {
        CloudFunction().logError('Error retrieving favorites trip list:  ${e.toString()}');
        return null;
      }
    }
    // get trips stream
    Stream<List<Trip>> favoriteTrips = tripCollection.where('favorite', arrayContainsAny: [userService.currentUserID]).snapshots()
        .map(_tripListFromSnapshot);
    _loadedDataFavoriteTrips.addStream(favoriteTrips);

  }

    Stream<List<Trip>> trips() => _loadedDataCurrentTrips.stream;
    Stream<List<Trip>> tripsPast() => _loadedDataPastTrips.stream;
    Stream<List<Trip>> tripsPrivate() => _loadedDataPrivateTrips.stream;
    Stream<List<Trip>> tripsAll() => _loadedDataAllTrips.stream;
    Stream<List<Trip>> tripsFavorite() => _loadedDataFavoriteTrips.stream;
}
