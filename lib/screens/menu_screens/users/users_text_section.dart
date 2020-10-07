import 'package:flutter/material.dart';

import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'user_profile_page.dart';


class UsersTextSection extends StatefulWidget{

  final UserProfile allUsers;
  UsersTextSection({this.allUsers,});

  @override
  _UsersTextSectionState createState() => _UsersTextSectionState();
}

class _UsersTextSectionState extends State<UsersTextSection> {
  var userService = locator<UserService>();

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  List blockedList =  [];

  @override
  void initState()  {
    super.initState();
    createBlockList(widget.allUsers.uid);

  }
  void createBlockList(String uid){
    try {
      currentUserProfile.blockedList.forEach((element) {
        if(!blockedList.contains(element)){
          blockedList.add(element);
        }
      });
    } catch (e){
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {



    return Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage(user: widget.allUsers,)),
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
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/blank_profile_picture.png',
                        image: widget.allUsers.urlToImage,
                        height: 75,
                        width: 75,
                        fit: BoxFit.fill,
                      ),
                      ),
                  ),
                  title: Text('${widget.allUsers.firstName} ${widget.allUsers.lastName}'),
                  subtitle: Text("${widget.allUsers.displayName}",
                    textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,),
//              isThreeLine: true,
                  trailing: !(blockedList.contains(widget.allUsers.uid)) ? PopupMenuButton<String>(
                    onSelected: (value){
                      switch (value) {
                        case "block":
                          {
                            TravelCrewAlertDialogs().blockAlert(context, widget.allUsers.uid);
                          }
                          break;
                        case "report":
                          {
                            TravelCrewAlertDialogs().reportAlert(context: context, userProfile: widget.allUsers, type:'userAccount');
                          }

                          break;
                        default:
                          {

                          }
                          break;
                      }
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) =>[
                      const PopupMenuItem(
                        value: 'block',
                        child: ListTile(
                          leading: Icon(Icons.block),
                          title: Text('Block Account'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: ListTile(
                          leading: Icon(Icons.report),
                          title: Text('Report'),
                        ),
                      ),
                    ],
                  ):
                  PopupMenuButton<String>(
                    onSelected: (value){
                      switch (value) {
                        case "unblock":
                          {
                            CloudFunction().unBlockUser(widget.allUsers.uid);
                            TravelCrewAlertDialogs().unblockDialog(context);
                          }
                          break;
                        default:
                          {

                          }
                          break;
                      }
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) =>[
                      const PopupMenuItem(
                        value: 'unblock',
                        child: ListTile(
                          leading: Icon(Icons.block),
                          title: Text('Unblock'),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.allUsers.followers.contains(userService.currentUserID) ? FlatButton(
                  child:  Text('Remove'),
                  shape: Border.all(width: 1, color: Colors.blue),
                  onPressed: () {
                    if(blockedList.contains(widget.allUsers.uid)){
                    } else {
                      CloudFunction().unFollowUser(widget.allUsers.uid);
                    }
                    //Unfollow user

                    // DatabaseService(uid: userService.currentUserID).unFollowUser(allUsers.uid);
                     },
                ) : FlatButton(
                  child:  Text('Follow'),
                  shape: Border.all(width: 1, color: Colors.blue),
                  onPressed: () {
                    // Send a follow request notification to user
                    var message = 'Follow request from ${currentUserProfile.displayName}';
                    var type = 'Follow';
                    if(userService.currentUserID != widget.allUsers.uid) {
                      if(blockedList.contains(widget.allUsers.uid)){
                      } else {
                        CloudFunction().addNewNotification(message: message,
                            ownerID: widget.allUsers.uid,
                            documentID: widget.allUsers.uid,
                            type: type,
                            uidToUse: currentUserProfile.uid);
                        _showDialog(context);
                      }
                      // DatabaseService().addNewNotificationData(
                      //     message: message, type:type, ownerID:allUsers.uid,documentID:allUsers.uid );

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