import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../services/widgets/loading.dart';

class ProfileWidget extends StatelessWidget {
  final UserPublicProfile user;
  final profileSize = SizeConfig.screenWidth * .45;
  final currentUserProfile =
      locator<UserProfileService>().currentUserProfileDirect();
  ProfileWidget({
    Key key,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 6,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(10.0, sizeFromHangingTheme, 10.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: Hero(
                      tag: user.uid,
                      transitionOnUserGestures: true,
                      child: Container(
                        height: profileSize,
                        width: profileSize,
                        child: CircleAvatar(
                          radius: SizeConfig.screenWidth / 1.8,
                          backgroundImage: user.urlToImage?.isNotEmpty ?? false
                              ? NetworkImage(
                                  user.urlToImage,
                                )
                              : AssetImage(profileImagePlaceholder),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      // width: double.infinity,
                      padding: EdgeInsets.only(
                          right: 8.0, left: 8.0, top: sizeFromHangingTheme / 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            textScaleFactor: 1.1,
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 2,
                          ),
                          SizedBox(
                            height: SizeConfig.screenHeight * .01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const IconThemeWidget(
                                icon: Icons.person,
                              ),
                              Flexible(
                                  child: Text(
                                user.displayName,
                                style: Theme.of(context).textTheme.subtitle1,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const IconThemeWidget(
                                icon: Icons.location_pin,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (user.hometown.isNotEmpty)
                                        ? Text(
                                            user.hometown,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          )
                                        : Text('Hometown',
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(flex: 2, child: FollowerBar(user: user)),
          Flexible(
            flex: 3,
            child: Card(
                margin: EdgeInsets.fromLTRB(SizeConfig.screenWidth / 7.0, 0,
                    SizeConfig.screenWidth / 7.0, 0),
                color: ReusableThemeColor().cardColor(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: SizeConfig.screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text(
                          'Destination Wish List',
                          style: Theme.of(context).textTheme.subtitle1,
                          textScaleFactor: 1.1,
                        )),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (user.topDestinations[0].isNotEmpty)
                                  ? Text(
                                      user.topDestinations[0],
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    )
                                  : Text(
                                      'Destination 1',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                              (user.topDestinations[1].isNotEmpty)
                                  ? Text(
                                      user.topDestinations[1],
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    )
                                  : Text(
                                      'Destination 2',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                              (user.topDestinations[2].isNotEmpty)
                                  ? Text(
                                      user.topDestinations[2],
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                      maxLines: 1,
                                    )
                                  : Text(
                                      'Destination 3',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ))),
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            flex: 3,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.fromLTRB(SizeConfig.screenWidth / 7.0, 0,
                    SizeConfig.screenWidth / 7.0, 0),
                color: ReusableThemeColor().cardColor(context),
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: SizeConfig.screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                            child: Text(
                          'Social Media',
                          style: Theme.of(context).textTheme.subtitle1,
                          textScaleFactor: 1.1,
                        )),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IG: ',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              (user.instagramLink.isNotEmpty)
                                  ? GestureDetector(
                                      onTap: () {
                                        TCFunctions()
                                            .launchURL(user.instagramLink);
                                      },
                                      child: Text('Instagram Link',
                                          style: TextStyle(color: Colors.blue)))
                                  : Text(
                                      '',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Facebook: ',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              (user.facebookLink.isNotEmpty)
                                  ? GestureDetector(
                                      onTap: () {
                                        TCFunctions()
                                            .launchURL(user.facebookLink);
                                      },
                                      child: Text('Facebook Link',
                                          style: TextStyle(color: Colors.blue)))
                                  : Text(
                                      '',
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ))),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 58.0),
            child: Text(
              'Recent Trips',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                  height: 150,
                  child: RecentTripTile(
                    uid: user.uid,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class FollowerBar extends StatelessWidget {
  const FollowerBar({
    Key key,
    @required this.user,
  }) : super(key: key);

  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Followers', style: Theme.of(context).textTheme.subtitle1),
              Text(
                '${user.followers.length}',
                style: ReusableThemeColor().greenOrBlueTextColor(context),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Following', style: Theme.of(context).textTheme.subtitle1),
              Text('${user.following.length}',
                  style: ReusableThemeColor().greenOrBlueTextColor(context)),
            ],
          )
        ],
      ),
    );
  }
}

class FollowList extends StatefulWidget {
  final bool isFollowers;
  final UserPublicProfile user;

  const FollowList({Key key, this.isFollowers, this.user}) : super(key: key);
  @override
  _FollowListState createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  var showImage = false;
  String image;

  @override
  Widget build(BuildContext context) {
    return getMember(context, image, showImage);
  }

  Widget getMember(BuildContext context, String image, bool showImage) {
    return StreamBuilder(
      stream: DatabaseService().retrieveFollowList(widget.user),
      builder: (context, users) {
        if (users.hasError) {
          CloudFunction().logError(
              'Error streaming follow list in profile widget: ${users.error.toString()}');
        }
        if (users.hasData) {
          final List<UserPublicProfile> followList = users.data;
          return Stack(children: [
            ListView.builder(
              itemCount: followList.length,
              itemBuilder: (BuildContext context, int index) {
                final UserPublicProfile user = followList[index];
                return userCard(context, user, widget.user);
              },
            ),
            if (showImage) ...[
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ),
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Center(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            height: 300,
                            width: 300,
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
                            profileImagePlaceholder,
                            height: 300,
                            width: 300,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
              ),
            ],
          ]);
        } else {
          return Loading();
        }
      },
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile member,
      UserPublicProfile profile) {
    return Card(
      color: ReusableThemeColor().cardColor(context),
      key: Key(member.uid),
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            showImage = true;
            image = member.urlToImage;
          });
        },
        onLongPressEnd: (LongPressEndDetails details) {
          setState(() {
            showImage = false;
          });
        },
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.blue,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: member.urlToImage != null
                  ? Image.network(
                      member.urlToImage,
                      height: 75,
                      width: 75,
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
          ),
          title: Text(
            member.displayName,
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: TextAlign.start,
          ),
          trailing: (profile.uid == currentUserProfile.uid)
              ? trailingButton(member)
              : null,
        ),
      ),
    );
  }

  Widget trailingButton(UserPublicProfile member) {
    return (!currentUserProfile.following.contains(member.uid))
        ? ElevatedButton(
            onPressed: () {
              // Send a follow request notification to user
              final String message =
                  'Follow request from ${currentUserProfile.displayName}';
              const String type = 'Follow';
              if (userService.currentUserID != member.uid) {
                if (currentUserProfile.blockedList.contains(member.uid)) {
                } else {
                  CloudFunction().addNewNotification(
                      message: message,
                      ownerID: member.uid,
                      documentID: member.uid,
                      type: type,
                      uidToUse: currentUserProfile.uid);
                  TravelCrewAlertDialogs().followRequestDialog(context);
                }
              }
            },
            child: Text('Follow Back',
                style: Theme.of(context).textTheme.subtitle1),
          )
        : ElevatedButton(
            onPressed: () {
              if (currentUserProfile.blockedList.contains(member.uid)) {
              } else {
                TravelCrewAlertDialogs().unFollowAlert(context, member.uid);
              }
            },
            child:
                Text('Unfollow', style: Theme.of(context).textTheme.subtitle1),
          );
  }
}
