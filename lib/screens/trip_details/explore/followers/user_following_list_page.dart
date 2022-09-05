import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';
import '../../../../models/trip_model.dart';
import '../../../../services/constants/constants.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/locator.dart';
import '../../../../services/widgets/loading.dart';
import '../../../alerts/alert_dialogs.dart';

/// Following list
class FollowingList extends StatefulWidget{
  const FollowingList({required this.trip});

  final Trip trip;

  @override
  _FollowingListState createState() => _FollowingListState();
}

class _FollowingListState extends State<FollowingList> {

  UserPublicProfile currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  bool _showImage = false;
  late String _image;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Followers',style: Theme.of(context).textTheme.headline5,),
      ),
      body: StreamBuilder(
        stream: DatabaseService().retrieveFollowingList(),
        builder: (BuildContext context, AsyncSnapshot<Object?> users) {
          if(users.hasError){
           CloudFunction().logError('Error streaming Following list for invites: ${users.error.toString()}');
          }
          if (users.hasData) {
            final List<UserPublicProfile> usersList = users.data as List<UserPublicProfile>;
            final List<UserPublicProfile> followingList =
            usersList.where((UserPublicProfile user) => currentUserProfile.following.contains(user.uid)).toList();
            return Stack(
              children: [
                ListView.builder(
                  itemCount: followingList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final UserPublicProfile user = followingList[index];
                    return userCard(context, user);
                  },
                ),
                if (_showImage) ...[
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
                    child: Container(
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: _image.isNotEmpty ? Image.network(_image,height: 300,
                            width: 300, fit: BoxFit.fill,) : Image.asset(
                            profileImagePlaceholder,height: 300,
                            width: 300,fit: BoxFit.fill,),
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
      ),
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile user){
    return Card(
      child: Container(
          child: GestureDetector(
            onLongPress: (){
              setState(() {
                _showImage = true;
                _image = user.urlToImage;
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
                  child: user.urlToImage.isNotEmpty  ? Image.network(user.urlToImage,fit: BoxFit.fill,):
                  Image.asset(profileImagePlaceholder,fit: BoxFit.fill,),
                ),
              ),
              title: Text('${user.firstName} ${user.lastName}'),
              subtitle: Text(user.displayName,
                textAlign: TextAlign.start,style: Theme.of(context).textTheme.subtitle2,),
              trailing: !widget.trip.accessUsers.contains(user.uid) ? IconButton(
                icon: const Icon(Icons.add),
                onPressed: (){
                  final String message = '${currentUserProfile.displayName} invited you to ${widget.trip.tripName}.';
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
              ) : const Icon(Icons.check_box),
            ),
          ),
        ),
      );
  }


}