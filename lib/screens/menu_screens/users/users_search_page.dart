import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';
import '../../../loading.dart';


class UsersSearchPage extends StatelessWidget{

  Trip tripDetails;
  UsersSearchPage({this.tripDetails});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: FutureBuilder(
        future: DatabaseService(uid: currentUser.uid).retrieveFollowingList(),
        builder: (context, users) {
          if (users.hasData) {
            return ListView.builder(
                itemCount: users.data.length,
                itemBuilder: (context, index) {
                  UserProfile user = users.data[index];
                  return userCard(context, user, currentUser);
                },
              );
          } else {
            return Loading();
          }
        },
      ),
    );
  }
  Widget userCard(BuildContext context, UserProfile user, User currentUser){
    return Card(
      child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.blue,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: user.urlToImage != null ? Image.network(user.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
                  ),
                ),
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text("${user.displayName}",
                  textAlign: TextAlign.start,),
                trailing: !tripDetails.accessUsers.contains(user.uid) ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    var message = '${currentUser.displayName} invited you to ${tripDetails.location}.';
                    var type = 'Invite';
                    DatabaseService().addNewNotificationData(message, tripDetails.documentId, type, user.uid);
                    _showDialog(context);
                  },
                ) : Icon(Icons.check_box),
              ),
            ],
          ),
        ),
      );
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Invite sent.')));
  }
}