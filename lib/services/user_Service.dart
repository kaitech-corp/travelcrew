import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/custom_objects.dart';

class UserService {

  final CollectionReference userPublicProfileCollection = FirebaseFirestore.instance.collection("userPublicProfile");

  Future<UserPublicProfile> retrieveUserPublicProfile(String uid) async {
    var ref = await userPublicProfileCollection.doc(uid).get();
    if(ref.exists){
      Map<String, dynamic> data = ref.data();
      return UserPublicProfile(
        displayName: data['displayName'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        urlToImage: data['urlToImage'],
      );
    } else {
      return null;
    }
  }
}