import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../services/constants/constants.dart';
import '../../../../services/database.dart';
import '../../../../services/widgets/loading.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/functions/cloud_functions/admin_functions.dart';
import '../../../services/functions/cloud_functions/notification_functions.dart';
import '../../Alerts/alert_dialogs.dart';
import '../../Profile/logic/logic.dart';
import '../../Trip_Management/logic/logic.dart';
import '../../Users/all_users_page.dart';

/// Following list
class FollowingList extends StatefulWidget {
  const FollowingList({super.key, required this.trip});

  final Trip trip;

  @override
  State<FollowingList> createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {
  bool _showImage = false;
  late String _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<UserPublicProfile>>(
        stream: retrieveFollowingList(),
        builder: (BuildContext context,
            AsyncSnapshot<List<UserPublicProfile>> users) {
          if (users.hasError) {
            AdminCloudFunction().logError(
                'Error streaming Following list for invites: ${users.error}');
          }
          if (users.hasData) {
            final List<UserPublicProfile> followingList = users.data!;
            return Stack(children: <Widget>[
              UserSearchBar(
                placeholder: ListView.builder(
                  itemCount: followingList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final UserPublicProfile user = followingList[index];
                    return userCard(context, user);
                  },
                ),
                displayChild: true,
                trip: widget.trip,
              ),
              if (_showImage) ...<Widget>[
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
                      child: _image.isNotEmpty
                          ? Image.network(
                              _image,
                              height: 300,
                              width: 300,
                              fit: BoxFit.fill,
                            )
                          : Image.network(
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
            return const Loading();
          }
        },
      ),
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile user) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showImage = true;
          _image = user.urlToImage ?? profileImagePlaceholder;
        });
      },
      onLongPressEnd: (LongPressEndDetails details) {
        setState(() {
          _showImage = false;
        });
      },
      child: UserCardLayout(
        trip: widget.trip,
        user: user,
      ),
    );
  }
}

class UserCardLayout extends StatelessWidget {
  const UserCardLayout({
    super.key,
    required this.user,
    required this.trip,
  });

  final UserPublicProfile user;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: defaultPadding,
          right: defaultPadding,
          bottom: defaultPadding / 2,
          top: defaultPadding / 2),
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
              child: (user.urlToImage != null && user.urlToImage!.isNotEmpty)
                  ? Image.network(
                      user.urlToImage!,
                      fit: BoxFit.fill,
                    )
                  : Image.network(
                      profileImagePlaceholder,
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          title: Text(
            user.displayName,
          ),
          trailing: trip.accessUsers.contains(user.uid)
              ? const Icon(Icons.check_box)
              : IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final UserPublicProfile profile =
                        await getUserProfile(userService.currentUserID);
                    final String message =
                        '${profile.displayName} invited you to ${trip.tripName}.';
                    const String type = 'Invite';
                    NotificationCloudFunction().addNewNotification(
                        ownerID: user.uid,
                        message: message,
                        documentID: trip.documentId,
                        type: type,
                        ispublic: trip.ispublic,
                        uidToUse: user.uid);
                    TravelCrewAlertDialogs().invitationDialog(context);
                  },
                )),
    );
  }
}
