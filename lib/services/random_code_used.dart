// Future testUserPublicProfileData() async {
//   var ref = userPublicProfileCollection.doc('YWpc01GzNCajEE4yRQjMO7fsIQo1');
//   try {
//     await ref.set({
//       'blockedList': [],
//       'displayName': 'userIQo1',
//       'email': 'rogerstwana@yahoo.com',
//       'followers': [],
//       'following': [],
//       'firstName': '',
//       'lastName': '',
//       'tripsCreated': 0,
//       'tripsJoined': 0,
//       'uid': 'YWpc01GzNCajEE4yRQjMO7fsIQo1',
//       'urlToImage': ''
//     });
//   } catch (e) {
//     print('Error creating Public: ${e.toString()}');
//     _analyticsService.writeError('Error creating Public: ${e.toString()}');
//   }
// }
//
// Future addTimeStampToUser() async {
//   var ref = await userCollection.get();
//   ref.docs.forEach((doc) {
//     userCollection.doc(doc.id).update({
//       'dateJoinedTimeStamp': FieldValue.serverTimestamp(),
//     });
//   });
// }



