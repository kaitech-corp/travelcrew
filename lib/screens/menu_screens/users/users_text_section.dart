import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';
import 'user_profile_page.dart';


class UsersTextSection extends StatelessWidget{
  final UserProfile allUsers;

  UsersTextSection({this.allUsers,});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);


    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage(user: allUsers,)),
          );

        },
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
                    child: allUsers.urlToImage != null ? Image.network(allUsers.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
                  ),
                ),
                title: Text('${allUsers.firstName} ${allUsers.lastName}'),
                subtitle: Text("${allUsers.displayName}",
                  textAlign: TextAlign.start,),
//              isThreeLine: true,
              ),
              allUsers.followers.contains(user.uid) ? FlatButton(
                child:  Text('Remove'),
                shape: Border.all(width: 1, color: Colors.blue),
                onPressed: () {
                  //Unfollow user
                  DatabaseService(uid: user.uid).unFollowUser(allUsers.uid);
                   },
              ) : FlatButton(
                child:  Text('Follow'),
                shape: Border.all(width: 1, color: Colors.blue),
                onPressed: () {
                  // Send a follow request notification to user
                  var message = 'Follow request from ${user.displayName}';
                  var type = 'Follow';
                  if(user.uid != allUsers.uid) {
                    DatabaseService(uid: user.uid).addNewNotificationData(
                        message, user.uid, type, allUsers.uid);
                    _showDialog(context);
                  }
                   },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Request sent.')));
  }
}