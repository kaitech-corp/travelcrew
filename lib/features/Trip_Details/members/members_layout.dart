import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';
import '../../../../models/trip_model.dart';
import '../../../../services/constants/constants.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/locator.dart';
import '../../../../services/navigation/route_names.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../Alerts/alert_dialogs.dart';


/// Layout list for members of trip
class MembersLayout extends StatefulWidget{

  const MembersLayout({Key? key, required this.trip, required this.ownerID}) : super(key: key);

  final Trip trip;
  final String ownerID;

  @override
  State<MembersLayout> createState() => _MembersLayoutState();
}

class _MembersLayoutState extends State<MembersLayout> {

  bool _showImage = false;
  late String _image;
  UserService userService = locator<UserService>();

  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
  return getMember(context, widget.trip);
  }


  Widget getMember(BuildContext context, Trip trip){
    return Stack(
      children: <Widget>[
        StreamBuilder<List<UserPublicProfile>>(
          builder: (BuildContext context, AsyncSnapshot<List<UserPublicProfile>> userData){
            if(userData.hasError){
              CloudFunction()
                  .logError('Error streaming user data '
                  'for members layout: ${userData.error}');
            }
            if(userData.hasData){
              final List<UserPublicProfile> crew = userData.data!;
              return ListView.builder(
                    itemCount: crew.length,
                    itemBuilder: (BuildContext context, int index) {
                      final UserPublicProfile member = crew[index];
                      return userCard(context, member, trip);
                    },
                  );
            } else {
              return const Loading();
            }
          },
        stream: DatabaseService().getcrewList(widget.trip.accessUsers),),
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
                  height: SizeConfig.screenWidth*.5,
                  width: SizeConfig.screenWidth*.5,
                  fit: BoxFit.fill,)
                    : Image.network(
                  profileImagePlaceholder,
                  height: SizeConfig.screenWidth*.5,
                  width: SizeConfig.screenWidth*.5,
                  fit: BoxFit.fill,),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile member, Trip trip){

    return Card(
      key: Key(member.uid),
      color: Colors.white,
      child: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight*.09,
        padding: const EdgeInsets.all(2),
        child: GestureDetector(
          onLongPress: (){
            setState(() {
              _showImage = true;
              _image = member.urlToImage;
            });
          },
          onLongPressEnd: (LongPressEndDetails details) {
            setState(() {
              _showImage = false;
            });
          },
          onTap: (){
            navigationService.navigateTo(UserProfilePageRoute, arguments: member);
          },
          child: Row(
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: SizeConfig.blockSizeHorizontal*7,
                  backgroundImage: (member.urlToImage.isEmpty) ? const NetworkImage(profileImagePlaceholder) : NetworkImage(member.urlToImage),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(member.displayName,
                    style: titleMedium(context),
                    textAlign: TextAlign.start,),
                  trailing: (member.uid == userService.currentUserID || member.uid == trip.ownerID)
                      ? const IconThemeWidget(icon:Icons.check)
                  : IconButton(
                    icon: const IconThemeWidget(icon: Icons.close),
                    onPressed: (){
                      TravelCrewAlertDialogs()
                          .removeMemberAlert(context, trip, member,);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
