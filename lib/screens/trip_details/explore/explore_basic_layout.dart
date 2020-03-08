import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/services/database.dart';

class ExploreBasicLayout extends StatelessWidget{

  final Trip tripdetails;

  ExploreBasicLayout({this.tripdetails});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    return  Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ImageLayout("assests/images/barcelona.jpg"),
                ListTile(
                  title: Text('${tripdetails.location}'.toUpperCase(), style: TextStyle(fontSize: 20.0)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value){
                      switch (value){
                        case "Join":
                          {
                            String message = '${user.displayName} has requested to join your trip ${tripdetails.location}.';
                            String trip = tripdetails.documentId;
                            String type = 'joinRequest';
                            String ownerID = tripdetails.ownerID;
                              DatabaseService(tripDocID: tripdetails.documentId, uid: user.uid)
                                  .addNewNotificationData(message, trip, type, ownerID);
//
                              _showDialog(context);
                          }
                        break;
                        default: {
                          print(value);
                        }
                        break;
                      }
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) =>[
                      const PopupMenuItem(
                        value: 'Join',
                        child: ListTile(
                          leading: Icon(Icons.add),
                          title: Text('Request to Join'),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Owner', style: TextStyle(fontSize: 12.0),),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${tripdetails.travelType}'.toUpperCase()),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Start: ${tripdetails.startDate}'),
                            Text('End: ${tripdetails.endDate}')
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
                  child: Text(tripdetails.comment, textScaleFactor: 1.25,),
                ),
              ],
            ),
          ),
        )
    );
  }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Request Submitted')));
  }
}



//{
//String message = '${user.displayName} has requested to join your trip.';
//String trip = tripdetails.location;
//String type = 'joinRequest';
//for (var i = 0; i < tripdetails.accessUsers.length; i++) {
//String uid = tripdetails.accessUsers[i];
//DatabaseService(tripDocID: tripdetails.documentId)
//    .addNewNotificationData(
//message, trip, type, uid);
//}
//}