
///Model for current user
class CurrentUser {
  final List<String>? blockedList;
  final String? displayName;
  final String? email;
  final String? firstName;
  final List<String>? following;
  final List<String>? followers;
  final String? lastName;
  // final int tripsCreated;
  // final int tripsJoined;
  final String? uid;
  final String? urlToImage;
  final String? hometown;
  final String? instagramLink;
  final String? facebookLink;
  final List<String>? topDestinations;
  
  CurrentUser({this.blockedList, this.displayName, this.email, this.firstName, this.following, this.followers, this.lastName, this.uid, this.urlToImage, this.hometown, this.instagramLink, this.facebookLink, this.topDestinations,});

  CurrentUser.fromData(Map<String, dynamic> data)
      : blockedList = List<String>.from(data['blockedList']),
  displayName = data['displayName'],
  email = data['email'],
  firstName = data['firstName'],
  following = List<String>.from(data['following']),
  followers = List<String>.from(data['followers']),
  lastName = data['lastName'],
  uid = data['uid'],
  urlToImage = data['urlToImage'],
  hometown = data['hometown'],
  instagramLink = data['instagramLink'],
  facebookLink = data['facebookLink'],
  topDestinations = List<String>.from(data['topDestinations']);

  Map<String, dynamic> toJson() {
    return {
      'blockedList': blockedList,
      'displayName': displayName,
      'email': email,
      'firstName': firstName,
      'following': following,
      'followers': followers,
      'lastName': lastName,
      'uid': uid,
      'urlToImage': urlToImage,
      'hometown': hometown,
      'instagramLink': instagramLink,
      'facebookLink': facebookLink,
      'topDestinations': topDestinations,
    };
  }
}