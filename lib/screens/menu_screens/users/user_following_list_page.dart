import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../loading.dart';


class currentUserFollowingList extends StatelessWidget{

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  Trip tripDetails;
  currentUserFollowingList({this.tripDetails});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Followers',style: Theme.of(context).textTheme.headline3,),
      ),
      body: StreamBuilder(
        stream: DatabaseService().retrieveFollowingList(),
        builder: (context, users) {
          if (users.hasData) {
            return ListView.builder(
                itemCount: users.data.length,
                itemBuilder: (context, index) {
                  UserProfile user = users.data[index];
                  return userCard(context, user);
                },
              );
          } else {
            return Loading();
          }
        },
      ),
    );
  }
  Widget userCard(BuildContext context, UserProfile user){
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
                  textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,),
                trailing: !tripDetails.accessUsers.contains(user.uid) ? IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    var message = '${currentUserProfile.displayName} invited you to ${tripDetails.location}.';
                    var type = 'Invite';
                    CloudFunction().addNewNotification(
                        ownerID: user.uid,
                        message: message,
                        documentID: tripDetails.documentId,
                        type: type,
                        ispublic: tripDetails.ispublic,
                        uidToUse: user.uid);
                    // DatabaseService().addNewNotificationData(ownerID: user.uid, message: message, documentID:tripDetails.documentId, type:type, ispublic: tripDetails.ispublic);
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