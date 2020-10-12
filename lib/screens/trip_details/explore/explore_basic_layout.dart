import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';

class ExploreBasicLayout extends StatelessWidget{

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final Trip tripDetails;

  ExploreBasicLayout({this.tripDetails});

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ImageLayout(tripDetails.urlToImage != "" ? tripDetails.urlToImage : travelImage),
                ListTile(
                  title: Text('${tripDetails.location}'.toUpperCase(),style: TextStyle(fontSize: 20.0)),
                  subtitle: Text('Owner: ${tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                  trailing: IconButton(
                    icon: Icon(Icons.report,),
                    onPressed: (){
                      TravelCrewAlertDialogs().reportAlert(context: context, tripDetails: tripDetails, type: 'tripDetails');
                    },
                  ),
                ),
                RaisedButton(
                    shape: Border.all(width: 1, color: Colors.blue),
                  child: Text('Request to Join'),
                    onPressed: ()
                      {
                        String message = '${currentUserProfile.displayName} has requested to join your trip ${tripDetails.location}.';
                        String trip = tripDetails.documentId;
                        String type = 'joinRequest';
                        String ownerID = tripDetails.ownerID;
                        bool ispublic = tripDetails.ispublic;

                        CloudFunction().addNewNotification(message: message,
                        documentID: trip,
                        type: type,
                        ownerID: ownerID,
                        ispublic: ispublic,
                        );
                        TravelCrewAlertDialogs().showRequestDialog(context);
                      }
                  ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${tripDetails.travelType}'.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
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
              ],
            ),
          ),
        )
    );
  }
}



