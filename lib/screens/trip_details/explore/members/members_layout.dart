import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../../loading.dart';

class MembersLayout extends StatelessWidget{

  final List<Members> members;
  final Trip tripDetails;
  final String ownerID;
  var userService = locator<UserService>();
  final ScrollController controller = ScrollController();


  MembersLayout({Key key, this.members, this.tripDetails, this.ownerID}) : super(key: key);

  @override
  Widget build(BuildContext context) {

return retrieveMembers(context);
  }

  Widget retrieveMembers(BuildContext context) {

    return FutureBuilder(
      builder: (context, members) {
        if (members.hasData) {
          return ListView.builder(
            itemCount: members.data.length,
            itemBuilder: (context, index) {
              Members member = members.data[index];
              return userCard(context, member, tripDetails);
            },
          );
        } else {
          return Loading();
        }
      },
      future: DatabaseService().retrieveMembers(tripDetails.documentId, tripDetails.ispublic),
    );
  }

  Widget userCard(BuildContext context, Members member, Trip tripDetails){

    return Card(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ListTile(
              onTap: (){
              },
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
          ],
        ),
      ),
    );
  }

}