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
            height: SizeConfig.screenHeight*.135,
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    child: Hero(
                      tag: widget.allUsers
                      .uid,
                      transitionOnUserGestures: true,
                      child: CircleAvatar(
                        radius: SizeConfig.tablet ? SizeConfig.blockSizeHorizontal*8 : SizeConfig.blockSizeHorizontal*12,
                        backgroundImage: widget.allUsers.urlToImage.isNotEmpty ? NetworkImage(widget.allUsers.urlToImage,) : AssetImage(profileImagePlaceholder),
                      ),
                    )
                  ),
                ),
                Expanded(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ListTile(
                        // leading:
                        title: Text("${widget.allUsers.displayName}",style: SizeConfig.mobile ? Theme.of(context).textTheme.subtitle1 : Theme.of(context).textTheme.headline5),
                        subtitle: Text('${widget.allUsers.firstName} ${widget.allUsers.lastName}',
                          textAlign: TextAlign.start,style: SizeConfig.mobile ? Theme.of(context).textTheme.subtitle2 : Theme.of(context).textTheme.subtitle1,),
                        trailing: !(currentUserProfile.blockedList.contains(widget.allUsers.uid) ?? false) ? UnblockedPopupMenu(allUsers: widget.allUsers):
                        BlockedPopupMenu(allUsers: widget.allUsers),
                      ),
                      widget.allUsers.followers.contains(userService.currentUserID) ?
                      Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: ElevatedButton(
                          child: Text('Unfollow',style: Theme.of(context).textTheme.subtitle1),
                          onPressed: () {
                            if(currentUserProfile.blockedList.contains(widget.allUsers.uid)){
                            } else {
                              TravelCrewAlertDialogs().unFollowAlert(context, widget.allUsers.uid);
                            }
                          },
                        ),
                      ) :
                      Padding(
                        padding: const EdgeInsets.only(right:8.0),
                        child: ElevatedButton(
                          child: Text('Follow',style: Theme.of(context).textTheme.subtitle1),
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