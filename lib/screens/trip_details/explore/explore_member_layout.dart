import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/menu_screens/users/user_following_list_page.dart';
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
                ImageLayout(tripDetails.urlToImage != "" ? tripDetails.urlToImage : "assets/images/travelPics.png"),
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
                        case "Add":
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
                          leading: Icon(Icons.report),
                          title: Text('Report'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Add',
                        child: ListTile(
                          leading: Icon(Icons.person_add),
                          title: Text('Add Member'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Leave',
                        child: ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text('Leave Group'),
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
                BringListToDisplay(documentID: tripDetails.documentId,),
              ],
            ),
          ),
        )
    );
  }
}


