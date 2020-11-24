import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../../loading.dart';

class MembersLayout extends StatefulWidget{

  final List<Members> members;
  final Trip tripDetails;
  final String ownerID;

  MembersLayout({Key key, this.members, this.tripDetails, this.ownerID}) : super(key: key);

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

return retrieveMembers(context);
  }

  Widget retrieveMembers(BuildContext context) {

    return FutureBuilder(
      builder: (context, members) {
        if (members.hasData) {
          return Stack(
            children: [
              ListView.builder(
              itemCount: members.data.length,
              itemBuilder: (context, index) {
                Members member = members.data[index];
                return userCard(context, member, widget.tripDetails);
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
                        child: _image.isNotEmpty ? Image.network(_image, height: 300,
                          width: 300,fit: BoxFit.fill,) : Image.asset(
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
      future: DatabaseService().retrieveMembers(widget.tripDetails.documentId, widget.tripDetails.ispublic),
    );
  }

  Widget userCard(BuildContext context, Members member, Trip tripDetails){

    return Card(
      key: Key(member.uid),
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
                child: member.urlToImage != null ? Image.network(member.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
              ),
            ),
            title: Text('${member.firstName} ${member.lastName}',style: Theme.of(context).textTheme.subtitle1,),
            subtitle: Text("${member.displayName}",style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.start,),
            trailing: (member.uid == userService.currentUserID || member.uid == tripDetails.ownerID) ? const Icon(Icons.check)
            : IconButton(
              icon: const Icon(Icons.close),
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
