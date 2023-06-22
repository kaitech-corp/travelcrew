import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/constants/constants.dart';

// required: associates our `user_public_profile_model.dart` with the code generated by Freezed
part 'public_profile_model.freezed.dart';
// optional: Since our user_public_profileModel class is serializable, we must add this line.
// But if user_public_profileModel was not serializable, we could skip it.
part 'public_profile_model.g.dart';

///Model for database user_public_profile

@freezed
class UserPublicProfile with _$UserPublicProfile {
  const factory UserPublicProfile({
    required String displayName,
    String? email,
    String? facebookLink,
    String? firstName,
    String? hometown,
    String? instagramLink,
    String? lastName,
    List<String>? blockedList,
    List<String>? followers,
    List<String>? following,
    List<String>? topDestinations,
    int? tripsCreated,
    int? tripsJoined,
    required String uid,
    String? urlToImage,
  }) = _UserPublicProfile;

  factory UserPublicProfile.fromJson(Map<String, Object?> json) =>
      _$UserPublicProfileFromJson(json);

  factory UserPublicProfile.mock() {
    return const UserPublicProfile(
        tripsJoined: 0,
        tripsCreated: 0,
        hometown: 'hometown',
        instagramLink: 'instagramLink',
        facebookLink: 'facebookLink',
        topDestinations: [],
        blockedList: [],
        displayName: 'displayName',
        email: 'email',
        following: [],
        followers: [],
        firstName: 'firstName',
        lastName: 'lastName',
        uid: 'uid',
        urlToImage: profileImagePlaceholder);
  }
}
