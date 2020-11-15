import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/explore/followers/user_following_list_page.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'layout_widgets.dart';
import 'lists/item_lists.dart';


class ExploreMemberLayout extends StatelessWidget{

  final Trip tripDetails;
  var userService = locator<UserService>();

  ExploreMemberLayout({this.tripDetails});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Hero(
                  tag: tripDetails.urlToImage,
                  transitionOnUserGestures: true,
                  child: FadeInImage.assetNetwork(
                    placeholder: travelImage,
                    image: tripDetails.urlToImage,

                  ),
                ),
                ListTile(
                  title: Text('${tripDetails.location}'.toUpperCase(), style: TextStyle(fontSize: 20.0)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value){
                      switch (value) {
                        case "report":
                          {
                            TravelCrewAlertDialogs().reportAlert(context: context, tripDetails: tripDetails, type: 'tripDetails');
                          }
                          break;
                        case "Invite":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => currentUserFollowingList(tripDetails: tripDetails,)),
                            );
                          }
                          break;
                        case "Leave":
                          {
                            TravelCrewAlertDialogs().leaveTripAlert(context,userService.currentUserID, tripDetails);
                          }
                          break;
                        default:
                          {

                          }
                          break;
                      }
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) =>[
                      const PopupMenuItem(
                        value: 'report',
                        child: ListTile(
                          leading: const Icon(Icons.report),
                          title: const Text('Report'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Invite',
                        child: ListTile(
                          leading: const Icon(Icons.person_add),
                          title: const Text('Invite'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Leave',
                        child: ListTile(
                          leading: const Icon(Icons.exit_to_app),
                          title: const Text('Leave Group'),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Owner: ${tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${tripDetails.travelType}',style: Theme.of(context).textTheme.subtitle1,),
                        tripDetails.ispublic ? Text('Public',style: Theme.of(context).textTheme.subtitle1,) : Text('Private',style: Theme.of(context).textTheme.subtitle1,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Start: ${tripDetails.startDate}',style: Theme.of(context).textTheme.subtitle1,),
                            Text('End: ${tripDetails.endDate}',style: Theme.of(context).textTheme.subtitle1,)
                          ],
                        )
                      ],
                    )
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)
                  ),
                  child: Text(tripDetails.comment,style: Theme.of(context).textTheme.subtitle1,),
                ),
                ListWidget(tripDetails: tripDetails,),
                Container(height: 1,color: Colors.grey,),
                BringListToDisplay(documentID: tripDetails.documentId,),
              ],
            ),
          ),
        )
    );
  }
}


