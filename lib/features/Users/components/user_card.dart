import 'package:flutter/material.dart';

import '../../../../../services/constants/constants.dart';
import '../../../../../services/database.dart';
import '../../../../../services/functions/cloud_functions.dart';
import '../../../../../services/locator.dart';
import '../../../../../services/navigation/route_names.dart';
import '../../../../../services/theme/text_styles.dart';
import '../../../../../services/widgets/appearance_widgets.dart';
import '../../../../../size_config/size_config.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../Alerts/alert_dialogs.dart';

class TCUserCard extends StatefulWidget {
  const TCUserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserPublicProfile user;

  @override
  State<TCUserCard> createState() => _TCUserCardState();
}

class _TCUserCardState extends State<TCUserCard> {
  UserPublicProfile currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ReusableThemeColor().color(context),
      key: Key(widget.user.uid),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          navigationService.navigateTo(UserProfilePageRoute,
              arguments: widget.user);
        },
        child: SizedBox(
          height: SizeConfig.screenHeight * .12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Hero(
                  tag: widget.user.uid,
                  transitionOnUserGestures: true,
                  child: CircleAvatar(
                    radius: SizeConfig.tablet
                        ? SizeConfig.blockSizeHorizontal * 8
                        : SizeConfig.blockSizeHorizontal * 11,
                    backgroundImage: widget.user.urlToImage.isNotEmpty
                        ? NetworkImage(
                            widget.user.urlToImage,
                          )
                        : const NetworkImage(profileImagePlaceholder),
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
                        currentUserProfile.blockedList, widget.user)),
              )
            ],
          ),
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
    Key? key,
    required this.user,
  }) : super(key: key);

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
              CloudFunction().unBlockUser(user.uid);
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
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white30,
      icon: const IconThemeWidget(
        icon: Icons.more_horiz,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'chat':
            {
              navigationService.navigateTo(DMChatRoute, arguments: user);
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
          value: 'chat',
          child: ListTile(
            leading: const IconThemeWidget(
              icon: Icons.message,
            ),
            title: Text('Chat', style: titleSmall(context)),
          ),
        ),
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
