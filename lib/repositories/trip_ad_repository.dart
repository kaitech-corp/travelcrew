import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class TripAdRepository {

  final CollectionReference adsCollection = FirebaseFirestore.instance.collection('tripAds');
  final _loadedData = StreamController<List<TripAds>>.broadcast();

  void dispose() {
    _loadedData.close();
  }

  void refresh() {
// Get all Ads
    List<TripAds> _adListFromSnapshot(QuerySnapshot snapshot){

      try {
        return snapshot.docs.map((doc){
          Map<String, dynamic> data = doc.data();
          return TripAds(
            tripName: data['tripName'] ?? '',
            documentID: data['documentID'] ?? '',
            link: data['link'] ?? '',
            location: data['location'] ?? '',
            dateCreated: data['dateCreated'] ?? null,
            clicks: data['clicks'] ?? 0,
            favorites: List<String>.from(data['favorites']) ?? null,
            clickers: List<String>.from(data['clickers']) ?? null,
            urlToImage: data['urlToImage'] ?? '',
          );
        }).toList().reversed.toList();
      } catch (e) {
        CloudFunction().logError('Error retrieving ad list:  ${e.toString()}');
        return null;
      }

    }

    Stream<List<TripAds>> adList = adsCollection.snapshots().map(_adListFromSnapshot);
    _loadedData.addStream(adList);


  }

  Stream<List<TripAds>> tripAds() => _loadedData.stream;

}

