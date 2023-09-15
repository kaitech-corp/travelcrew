import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../services/constants/constants.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/loading.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../Alerts/alert_dialogs.dart';
import '../../Profile/logic/logic.dart';
import '../../Trip_Management/logic/logic.dart';

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
      appBar: AppBar(
        title: Text(
          'Followers',
          style: headlineMedium(context),
        ),
      ),
      body: StreamBuilder<List<UserPublicProfile>>(
        stream: retrieveFollowingList(),
        builder: (BuildContext context,
            AsyncSnapshot<List<UserPublicProfile>> users) {
          if (users.hasError) {
            CloudFunction().logError(
                'Error streaming Following list for invites: ${users.error}');
          }
          if (users.hasData) {
            final List<UserPublicProfile> followingList = users.data!;
            return Stack(children: <Widget>[
              ListView.builder(
                itemCount: followingList.length,
                itemBuilder: (BuildContext context, int index) {
                  final UserPublicProfile user = followingList[index];
                  return userCard(context, user);
                },
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
    return Card(
      child: GestureDetector(
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
                child: Image.network(
                  user.urlToImage ?? profileImagePlaceholder,
                  fit: BoxFit.fill,
                )),
          ),
          subtitle: Text(
            '${user.firstName} ${user.lastName}',
            textAlign: TextAlign.start,
            style: titleSmall(context),
          ),
          title: Text(
            user.displayName,
          ),
          trailing: !widget.trip.accessUsers.contains(user.uid)
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final UserPublicProfile profile =
                        await getUserProfile(userService.currentUserID);
                    final String message =
                        '${profile.displayName} invited you to ${widget.trip.tripName}.';
                    const String type = 'Invite';
                    CloudFunction().addNewNotification(
                        ownerID: user.uid,
                        message: message,
                        documentID: widget.trip.documentId,
                        type: type,
                        ispublic: widget.trip.ispublic,
                        uidToUse: user.uid);
                    TravelCrewAlertDialogs().invitationDialog(context);
                  },
                )
              : const Icon(Icons.check_box),
        ),
      ),
    );
  }
}
