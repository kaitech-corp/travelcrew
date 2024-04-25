import 'package:flutter/material.dart';

import '../../../../../services/constants/constants.dart';
import '../../../../../services/database.dart';
import '../../../../../services/navigation/route_names.dart';
import '../../../../../services/theme/text_styles.dart';
import '../../../../../services/widgets/appearance_widgets.dart';
import '../../../../../size_config/size_config.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../services/functions/cloud_functions/user_functions.dart';
import '../../Alerts/alert_dialogs.dart';

class TCUserCard extends StatefulWidget {
  const TCUserCard({
    super.key,
    required this.user,
  });

  final UserPublicProfile user;

  @override
  State<TCUserCard> createState() => _TCUserCardState();
}

class _TCUserCardState extends State<TCUserCard> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {
        navigationService.navigateTo(UserProfilePageRoute,
            arguments: widget.user);
      },
      child: SizedBox(
        height: SizeConfig.screenHeight * .1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Hero(
                tag: widget.user.uid,
                transitionOnUserGestures: true,
                child: CircleAvatar(
                  radius: SizeConfig.tablet
                      ? SizeConfig.blockSizeHorizontal * 6
                      : SizeConfig.blockSizeHorizontal * 9,
                  backgroundImage: 
                      NetworkImage(
      (widget.user.urlToImage != null && widget.user.urlToImage!.isNotEmpty)
    ? widget.user.urlToImage!
    : profileImagePlaceholder,
    )
    
                     
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(widget.user.displayName,
                    style: SizeConfig.mobile
                        ? titleLarge(context)
                        : headlineMedium(context),),
              ),
            ),
            Expanded(
              child: Align(
                  alignment: Alignment.topRight,
                  child: checkBlockList(widget.user.uid,
                      currentUserProfile.userPublicProfile?.blockedList ?? <String>[], widget.user)),
            )
          ],
        ),
      ),
    );
  }
}

Widget checkBlockList(String uid, List<dynamic> blockedList,
    UserPublicProfile userPublicProfile) {
  if (blockedList.contains(uid)) {
    // show UnblockedPopupMenu for the user
    return BlockedPopupMenu(user: userPublicProfile) ;
  } else {
    // show BlockedPopupMenu for the user
    return UnblockedPopupMenu(user: userPublicProfile);
  }
}

class BlockedPopupMenu extends StatelessWidget {
  const BlockedPopupMenu({
    super.key,
    required this.user,
  });

  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const IconThemeWidget(
        icon: Icons.more_horiz,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'unblock':
            {
              UserCloudFunction().unBlockUser(user.uid);
              TravelCrewAlertDialogs().unblockDialog(context);
            }
            break;
          default:
            {}
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: 'unblock',
          child: ListTile(
            leading: const IconThemeWidget(
              icon: Icons.block,
            ),
            title:
                Text('Unblock', style: titleSmall(context)),
          ),
        ),
      ],
    );
  }
}

class UnblockedPopupMenu extends StatelessWidget {
  const UnblockedPopupMenu({
    super.key,
    required this.user,
  });

  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const IconThemeWidget(
        icon: Icons.more_horiz,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'follow':
            {
              UserCloudFunction().followUser(user.uid);
            }
            break;
          case 'block':
            {
              TravelCrewAlertDialogs().blockAlert(context, user.uid);
            }
            break;
          case 'report':
            {
              TravelCrewAlertDialogs().reportAlert(
                  context: context, userProfile: user, type: 'userAccount');
            }
            break;
          default:
            {}
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        PopupMenuItem<String>(
          value: 'block',
          child: ListTile(
            leading: const IconThemeWidget(
              icon: Icons.block,
            ),
            title: Text('Block Account',
                style: titleSmall(context)),
          ),
        ),
        PopupMenuItem<String>(
          value: 'report',
          child: ListTile(
            leading: const IconThemeWidget(
              icon: Icons.report,
            ),
            title: Text('Report', style: titleSmall(context)),
          ),
        ),
      ],
    );
  }
}
