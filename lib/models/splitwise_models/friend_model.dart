// import 'balance_model.dart';
// import 'current_user_model.dart';
// import 'groups_model.dart';
//
// class SW_FriendEntity {
//
//   final int id;
//   final String first_name;
//   final String last_name;
//   final String email;
//   final String registration_status;
//   // final Picture picture;
//   // final List<Groups> groups;
//   // final List<Balance> balance;
//   final String updated_at;
//
//   SW_FriendEntity.fromJsonMap(Map<String, dynamic> map):
//         id = map["id"],
//         first_name = map["first_name"],
//         last_name = map["last_name"],
//         email = map["email"],
//         registration_status = map["registration_status"],
//         // picture = Picture.fromJsonMap(map["picture"]),
//         // groups = List<Groups>.from(map["groups"].map((it) => Groups.fromJsonMap(it))),
//         // balance = List<Balance>.from(map["balance"].map((it) => Balance.fromJsonMap(it))),
//         updated_at = map["updated_at"];
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = id;
//     data['first_name'] = first_name;
//     data['last_name'] = last_name;
//     data['email'] = email;
//     data['registration_status'] = registration_status;
//     // data['picture'] = picture == null ? null : picture.toJson();
//     // data['groups'] = groups != null ?
//     // this.groups.map((v) => v.toJson()).toList()
//     //     : null;
//     // data['balance'] = balance != null ?
//     // this.balance.map((v) => v.toJson()).toList()
//     //     : null;
//     data['updated_at'] = updated_at;
//     return data;
//   }
// }
//
// class SW_FriendsEntity {
//
//   final List<SW_FriendEntity> friends;
//
//   SW_FriendsEntity.fromJsonMap(Map<String, dynamic> map):
//         friends = List<SW_FriendEntity>.from(map["friends"].map((it) => SW_FriendEntity.fromJsonMap(it)));
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['friends'] = friends != null ?
//     this.friends.map((v) => v.toJson()).toList()
//         : null;
//     return data;
//   }
// }
