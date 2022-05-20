import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';
import '../../../../models/trip_model.dart';
import '../../../../services/constants/constants.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/locator.dart';
import '../../../../services/navigation/route_names.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../../alerts/alert_dialogs.dart';

/// Layout list for members of trip
class MembersLayout extends StatefulWidget{

  final Trip tripDetails;
  final String ownerID;

  MembersLayout({Key key, this.tripDetails, this.ownerID}) : super(key: key);

  @override
  _MembersLayoutState createState() => _MembersLayoutState();
}

class _MembersLayoutState extends State<MembersLayout> {

  var _showImage = false;
  String _image;
  var userService = locator<UserService>();

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
  return getMember(context, widget.tripDetails);
  }


  Widget getMember(BuildContext context, Trip tripDetails){
    return Stack(
      children: [
        StreamBuilder<List<UserPublicProfile>>(
          builder: (context, userData){
            if(userData.hasError){
              CloudFunction()
                  .logError('Error streaming user data '
                  'for members layout: ${userData.error.toString()}');
            }
            if(userData.hasData){
              final List<UserPublicProfile> crew = userData.data;
              return ListView.builder(
                    itemCount: crew.length,
                    itemBuilder: (BuildContext context, int index) {
                      final UserPublicProfile member = crew[index];
                      return userCard(context, member, tripDetails);
                    },
                  );
            } else {
              return Loading();
            }
          },
        stream: DatabaseService().getcrewList(widget.tripDetails.accessUsers),),
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
                  child: _image.isNotEmpty
                      ? Image.network(
                    _image,
                    height: SizeConfig.screenWidth*.5,
                    width: SizeConfig.screenWidth*.5,
                    fit: BoxFit.fill,)
                      : Image.asset(
                    profileImagePlaceholder,
                    height: SizeConfig.screenWidth*.5,
                    width: SizeConfig.screenWidth*.5,
                    fit: BoxFit.fill,),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile member, Trip tripDetails){

    return Card(
      key: Key(member.uid),
      color: Colors.white,
      child: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight*.09,
        padding: EdgeInsets.all(2),
        child: GestureDetector(
          onLongPress: (){
            setState(() {
              _showImage = true;
              _image = member.urlToImage;
            });
          },
          onLongPressEnd: (details) {
            setState(() {
              _showImage = false;
            });
          },
          onTap: (){
            navigationService.navigateTo(UserProfilePageRoute, arguments: member);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: SizeConfig.blockSizeHorizontal*7,
                    backgroundImage: (member.urlToImage.isNotEmpty ?? false)
                        ? NetworkImage(member.urlToImage,)
                        : AssetImage(profileImagePlaceholder),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(member.displayName,
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.start,),
                    trailing: (member.uid == userService.currentUserID || member.uid == tripDetails.ownerID)
                        ? const IconThemeWidget(icon:Icons.check)
                    : IconButton(
                      icon: const IconThemeWidget(icon: Icons.close),
                      onPressed: (){
                        TravelCrewAlertDialogs()
                            .removeMemberAlert(context, tripDetails, member,);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
