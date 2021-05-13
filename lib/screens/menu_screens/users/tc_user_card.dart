import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/size_config/size_config.dart';


class TCUserCard extends StatefulWidget{

  final UserPublicProfile allUsers;
  TCUserCard({this.allUsers, this.heroTag,});
  final heroTag;

  @override
  _TCUserCardState createState() => _TCUserCardState();
}

class _TCUserCardState extends State<TCUserCard> {

  @override
  void initState()  {
    super.initState();

  }
 double _cardHeight  = (SizeConfig.screenHeight*.12);
  double _imageHeight = (SizeConfig.screenHeight*.12)*.75;
  @override
  Widget build(BuildContext context) {


    return Card(
      color: ReusableThemeColor().color(context),
      key: Key(widget.allUsers.uid),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            navigationService.navigateTo(UserProfilePageRoute, arguments: widget.allUsers);
          },
          child: Container(
            height: _cardHeight,
            child: Stack(
              // mainAxisSize: MainAxisSize.min,
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    width: _imageHeight,
                    height: _imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_imageHeight/2),
                      color: Colors.blue,
                    ),
                    child: Hero(
                      tag: widget.allUsers
                      .uid,
                      transitionOnUserGestures: true,
                      child: CircleAvatar(
                        radius: _imageHeight/2,
                        backgroundImage: widget.allUsers.urlToImage.isNotEmpty ? NetworkImage(widget.allUsers.urlToImage,) : AssetImage(profileImagePlaceholder),
                      ),
                    )
                  ),
                ),
                Positioned(
                  // left: 0,
                  // top: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: ListTile(
                      // leading:
                      title: Text("${widget.allUsers.displayName}"),
                      subtitle: Text('${widget.allUsers.firstName} ${widget.allUsers.lastName}',
                        textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,),
                      trailing: !(currentUserProfile.blockedList.contains(widget.allUsers.uid) ?? false) ? UnblockedPopupMenu(allUsers: widget.allUsers):
                      BlockedPopupMenu(allUsers: widget.allUsers),
                    ),
                  ),
                ),
                widget.allUsers.followers.contains(userService.currentUserID) ?
                Positioned(
                  right: 8,
                  bottom: 2,
                  child: FlatButton(
                    child: Text('Remove',style: Theme.of(context).textTheme.subtitle2),
                    shape: Border.all(width: 1, color: Colors.black),
                    onPressed: () {
                      if(currentUserProfile.blockedList.contains(widget.allUsers.uid)){
                      } else {
                        TravelCrewAlertDialogs().unFollowAlert(context, widget.allUsers.uid);
                      }
                      },
                  ),
                ) :
                Positioned(
                  right: 8,
                  bottom: 2,
                  child: FlatButton(
                    child: Text('Follow',style: Theme.of(context).textTheme.subtitle2),
                    shape: Border.all(width: 1, color: Color(0xAA2D3D49)),
                    onPressed: () {
                      // Send a follow request notification to user
                      var message = 'Follow request from ${currentUserProfile.displayName}';
                      var type = 'Follow';
                      if(userService.currentUserID != widget.allUsers.uid) {
                        if(currentUserProfile.blockedList.contains(widget.allUsers.uid)){
                        } else {
                          CloudFunction().addNewNotification(message: message,
                              ownerID: widget.allUsers.uid,
                              documentID: widget.allUsers.uid,
                              type: type,
                              uidToUse: currentUserProfile.uid);
                          TravelCrewAlertDialogs().followRequestDialog(context);
                        }
                      }
                       },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

class BlockedPopupMenu extends StatelessWidget {
  const BlockedPopupMenu({
    Key key,
    @required this.allUsers,
  }) : super(key: key);

  final UserPublicProfile allUsers;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value){
        switch (value) {
          case "unblock":
            {
              CloudFunction().unBlockUser(allUsers.uid);
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
        PopupMenuItem(
          value: 'unblock',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.block,),
            title: Text('Unblock',style: Theme.of(context).textTheme.subtitle2),
          ),
        ),
      ],
    );
  }
}

class UnblockedPopupMenu extends StatelessWidget {
  const UnblockedPopupMenu({
    Key key,
    @required this.allUsers,
  }) : super(key: key);

  final UserPublicProfile allUsers;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black,
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value){
        switch (value) {
          case "chat":
            {
              navigationService.navigateTo(DMChatRoute, arguments: allUsers);
            }
            break;
          case "block":
            {
              TravelCrewAlertDialogs().blockAlert(context, allUsers.uid);
            }
            break;
          case "report":
            {
              TravelCrewAlertDialogs().reportAlert(context: context, userProfile: allUsers, type:'userAccount');
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
         PopupMenuItem(
          value: 'chat',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.message,),
            title: Text('Chat',style: Theme.of(context).textTheme.subtitle2),
          ),
        ),
         PopupMenuItem(
          value: 'block',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.block,),
            title: Text('Block Account',style: Theme.of(context).textTheme.subtitle2),
          ),
        ),
         PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.report,),
            title: Text('Report',style: Theme.of(context).textTheme.subtitle2),
          ),
        ),
      ],
    );
  }
}