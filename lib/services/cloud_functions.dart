import 'package:cloud_functions/cloud_functions.dart';

class CloudFunction {

  // void sayHello() async {
  //   final HttpsCallable sayHello = CloudFunctions.instance.getHttpsCallable(functionName: 'sayHello');
  //   dynamic response = await sayHello.call().then((value) => {
  //     print(value.data)
  //   });
  //
  // }
  // Give feedback
  void giveFeedback(String message) async {
    final HttpsCallable giveFeedback = CloudFunctions.instance.getHttpsCallable(
        functionName: 'giveFeedback');
    giveFeedback({
      'message': message,
    }).then((value) =>
    {
      print('Feedback submitted.'),
    });
  }

  void joinTrip(String docID, String uid) async {
    final HttpsCallable joinTrip = CloudFunctions.instance.getHttpsCallable(
        functionName: 'joinTrip');
    joinTrip({
      'docID': docID,
      'uid': uid,
    }).then((value) =>
    {
      print('Join Trip completed'),
      addMember(docID, uid),
    });
  }

  void addMember(String docID, String uid) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addMember');
    addMember({
      'docID': docID,
      'uid': uid,
    }).then((value) =>
    {
      print('Added Member')
    });
  }


  void leaveTrip(String docID, String uid) async {
    final HttpsCallable joinTrip = CloudFunctions.instance.getHttpsCallable(
        functionName: 'leaveTrip');
    joinTrip({
      'docID': docID,
      'uid': uid,
    }).then((value) =>
    {
      print('Leave Trip completed'),
      removeMember(docID, uid),
    });
  }

  void removeMember(String docID, String uid) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeMember');
    addMember({
      'docID': docID,
      'uid': uid,
    }).then((value) =>
    {
      print('Removed Member')
    });
  }

  void removeLodging(String docID, String fieldID) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeLodging');
    addMember({
      'docID': docID,
      'fieldID': fieldID,
    }).then((value) =>
    {
      print('Removed Lodging')
    });
  }

  void removeActivity(String docID, String fieldID) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeActivity');
    addMember({
      'docID': docID,
      'fieldID': fieldID,
    }).then((value) =>
    {
      print('Removed Lodging')
    });
  }

  void addFavoriteToTrip(String docID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addFavoriteToTrip');
    functionData({
      'docID': docID,
      'uid': uid,
    }).then((value) =>
    {
      print('Added to favorite list')
    });
  }

  void removeFavoriteFromTrip(String docID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeFavoriteFromTrip');
    functionData({
      'docID': docID,
      'uid': uid,
    }).then((value) =>
    {
      print('Removed from favorite list')
    });
  }

  void addVoteToActivity(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addVoteToActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    }).then((value) =>
    {
      print('Added vote to Activity'),
      addVoterToActivity(docID, fieldID, uid)
    });
  }

  void addVoterToActivity(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addVoterToActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    }).then((value) =>
    {
      print('Added user to voter list')
    });
  }

  void removeVoteFromActivity(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeVoteFromActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    }).then((value) =>
    {
      print('removed vote from Activity'),
      removeVoterFromActivity(docID, fieldID, uid)
    });
  }

  void removeVoterFromActivity(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeVoterFromActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    }).then((value) =>
    {
      print('Removed user from voter list')
    });
  }

  void addVoteToLodging(String docID, String fieldID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addVoteToLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    }).then((value) =>
    {
      print('Added vote to Lodging')

    });
  }

  void addVoterToLodging(String docID, String fieldID, String uid) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addVoterToLodging');
    addMember({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    }).then((value) =>
    {
      print('Added user to voter list')
    });
  }

  void removeVoteFromLodging(String docID, String fieldID) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeVoteFromLodging');
    addMember({
      'docID': docID,
      'fieldID': fieldID,
    }).then((value) =>
    {
      print('removed vote from Lodging')
    });
  }

  void removeVoterFromLodging(String docID, String fieldID, String uid) async {
    final HttpsCallable addMember = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeVoterFromLodging');
    addMember({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    }).then((value) =>
    {
      print('Removed user from voter list')
    });
  }

}