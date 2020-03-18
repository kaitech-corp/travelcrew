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
                ImageLayout(tripdetails.urlToImage != "" ? tripdetails.urlToImage : "assests/images/travelPics.png"),
                ListTile(
                  title: Text('${tripdetails.location}'.toUpperCase(), style: TextStyle(fontSize: 20.0)),
                  subtitle: Text('Owner', style: TextStyle(fontSize: 12.0),),
                ),
                RaisedButton(
                    shape: Border.all(width: 1, color: Colors.blue),
                  child: Text('Request to Join'),
                    onPressed: ()
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
        .showSnackBar(SnackBar(content: Text('Request Submitted. Once accepted by owner this trip will appear under "My Crew"')));
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