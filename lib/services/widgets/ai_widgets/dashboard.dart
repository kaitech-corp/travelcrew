// import 'package:flutter/material.dart';
// import 'package:bloc/bloc.dart';
//
// class User {
//   String name;
//   String location;
//   int trips;
//
//   User(this.name, this.location, this.trips);
// }
//
// class UserBloc extends Bloc<List<User>, Map<String, int>> {
//   UserBloc(Map<String, int> initialState) : super(initialState);
//
//   Map<String, int> get initialState => {};
//
//   Stream<Map<String, int>> mapEventToState(List<User> users) async* {
//     final Map<String, int> userMap = <String, int>{};
//     int totalUsers = 0;
//
//     for (final user in users) {
//       totalUsers++;
//       if (userMap.containsKey(user.location)) {
//         userMap[user.location] += user.trips;
//       } else {
//         userMap[user.location] = user.trips;
//       }
//     }
//
//     yield {'totalUsers': totalUsers, 'userMap': userMap};
//   }
// }
//
// class UserList extends StatefulWidget {
//   final List<User> users;
//
//   UserList(this.users);
//
//   @override
//   _UserListState createState() => _UserListState();
// }
//
// class _UserListState extends State<UserList> {
//   UserBloc _bloc;
//
//   @override
//   void initState() {
//     super.initState();
//     _bloc = UserBloc();
//     _bloc.add(widget.users);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<Map<String, int>>(
//         stream: _bloc.state,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return Column(
//               children: <Widget>[
//                 Text('Total Users: ${snapshot.data['totalUsers']}'),
//                 Text('User Locations:'),
//                 ...snapshot.data['userMap'].entries.map((entry) => Text('${entry.key}: ${entry.value}')),
//               ],
//             );
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         });
//   }
// }