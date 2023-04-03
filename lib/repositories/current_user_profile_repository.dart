import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/custom_objects.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
/// It contains the public profile infos for all users.
///
/// Relies on a remote NoSQL document-oriented database.
class CurrentUserProfileRepository {

  final CollectionReference<Object> userPublicProfileCollection = FirebaseFirestore.instance.collection('userPublicProfile');
  final StreamController<UserPublicProfile> _loadedData = StreamController<UserPublicProfile>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    // Get Public Profile
    UserPublicProfile userProfileFromSnapshot(DocumentSnapshot<Object> snapshot){
      if(snapshot.exists) {
        try {
          // final Map<String, dynamic> data = snapshot.data()  as Map<String, dynamic>;
          // urlToImage.value = UserPublicProfile.fromData(data).urlToImage ?? '';
          return UserPublicProfile.fromDocument(snapshot);
        } catch(e){
          CloudFunction().logError('Error retrieving single user profile:  $e');
          return defaultProfile;
        }} else {
        return defaultProfile;
      }
    }

    final Stream<UserPublicProfile> profile = userPublicProfileCollection
        .doc(userService.currentUserID)
        .snapshots().map(userProfileFromSnapshot);



    _loadedData.addStream(profile);


  }

  Stream<UserPublicProfile> profile() => _loadedData.stream;

}

// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../../models/custom_objects.dart';
// import '../../../services/database.dart';
// import '../../../services/functions/cloud_functions.dart';

// /// Interface to our 'userPublicProfile' Firebase collection.
// /// It contains the public profile infos for all users.
// ///
// /// Relies on a remote NoSQL document-oriented database.
// class CurrentUserProfileRepository {
//   final CollectionReference<Object> _userPublicProfileCollection =
//       FirebaseFirestore.instance.collection('userPublicProfile');
//   final StreamController<UserPublicProfile> _loadedData =
//       StreamController<UserPublicProfile>.broadcast();

//   StreamSubscription<DocumentSnapshot<Object>>? _subscription;

//   void dispose() {
//     _loadedData.close();
//     _subscription?.cancel();
//   }

//   void refresh() {
//     _subscription?.cancel();
//     _subscription = _userPublicProfileCollection
//         .doc(userService.currentUserID)
//         .snapshots()
//         .map((snapshot) =>
//             snapshot.exists ? UserPublicProfile.fromDocument(snapshot) : defaultProfile)
//         .handleError((error) =>
//             CloudFunction().logError('Error retrieving single user profile: $error'))
//         .listen((profile) => _loadedData.add(profile));
//   }

//   Stream<UserPublicProfile> profile() => _loadedData.stream;
// }
