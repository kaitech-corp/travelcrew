
///Model for current user
class CurrentUser {
  
  CurrentUser({this.blockedList, this.displayName, this.email, this.firstName, this.following, this.followers, this.lastName, required this.uid, this.urlToImage, this.hometown, this.instagramLink, this.facebookLink, this.topDestinations,});

  CurrentUser.fromData(Map<String, dynamic> data)
      : blockedList = List<String>.from(data['blockedList'] as List<String>),
  displayName = data['displayName'] as String,
  email = data['email'] as String,
  firstName = data['firstName'] as String,
  following = List<String>.from(data['following']as List<String>),
  followers = List<String>.from(data['followers'] as List<String>),
  lastName = data['lastName'] as String,
  uid = data['uid'] as String,
  urlToImage = data['urlToImage'] as String,
  hometown = data['hometown'] as String,
  instagramLink = data['instagramLink'] as String,
  facebookLink = data['facebookLink'] as String,
  topDestinations = List<String>.from(data['topDestinations'] as List<String>);

  final List<String>? blockedList;
  final String? displayName;
  final String? email;
  final String? firstName;
  final List<String>? following;
  final List<String>? followers;
  final String? lastName;
  final String uid;
  final String? urlToImage;
  final String? hometown;
  final String? instagramLink;
  final String? facebookLink;
  final List<String>? topDestinations;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
