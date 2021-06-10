import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../../services/widgets/loading.dart';

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
        StreamBuilder(
          builder: (context, userData){
            if(userData.hasError){
              CloudFunction().logError('Error streaming user data for members layout: ${userData.error.toString()}');
            }
            if(userData.hasData){
              List<UserPublicProfile> crew = userData.data;
              return ListView.builder(
                    itemCount: crew.length,
                    itemBuilder: (context, index) {
                      UserPublicProfile member = crew[index];
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
                  child: _image.isNotEmpty ? Image.network(_image, height: 300,
                    width: 300,fit: BoxFit.fill,) : Image.asset(
                    profileImagePlaceholder,height: 300,
                    width: 300,fit: BoxFit.fill,),
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
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
      child: Container(
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
                child: member.urlToImage.isNotEmpty ? Image.network(member.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
              ),
            ),
            title: Text("${member.displayName}",style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.start,),
            trailing: (member.uid == userService.currentUserID || member.uid == tripDetails.ownerID) ? IconThemeWidget(icon:Icons.check)
            : IconButton(
              icon: IconThemeWidget(icon: Icons.close),
              onPressed: (){
                TravelCrewAlertDialogs().removeMemberAlert(context, tripDetails, member,);
              },
            ),
          ),
        ),
      ),
    );
  }
}
