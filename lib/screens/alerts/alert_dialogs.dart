import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/menu_screens/help/report.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';

class TravelCrewAlertDialogs {
  var userService = locator<UserService>();

  var reportMessage = "Submit a report and we will review this report within 24 hrs and "
      "if deemed inappropriate we will take action by removing the "
      "content and/or account within that timeframe.";

  var blockMessage = 'This user will be removed from all of your trips (public and private) and '
      ' will not be able to view any of your content. Please note this user will not be removed from '
      'shared trips where neither party is the owner. It is your responsibility to exit such trips.';

  Future<void> blockAlert(BuildContext context, String blockedUserID) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Block Account',style: Theme.of(context).textTheme.subtitle1,),
          content: Text(
              blockMessage,style: Theme.of(context).textTheme.subtitle1,),
          actions: <Widget>[
            FlatButton(
              child: Text('Block',style: Theme.of(context).textTheme.subtitle1,),
              onPressed: () {
                CloudFunction().blockUser(blockedUserID);
                Navigator.pop(context);
                submittedAlert(context);
              },
            ),
            FlatButton(
              child: Text('Cancel',style: Theme.of(context).textTheme.subtitle1,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> reportAlert({BuildContext context, Trip tripDetails, UserProfile userProfile, ActivityData activityData, LodgingData lodgingData, String type}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report',style: Theme.of(context).textTheme.subtitle1,),
          content: Text(
              reportMessage,style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            FlatButton(
              child: Text('Report',style: Theme.of(context).textTheme.subtitle1,),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportContent(type: type, tripDetails: tripDetails, userAccount: userProfile, activity: activityData, lodging: lodgingData,)),
                );
              },
            ),
            FlatButton(
              child: Text('Cancel',style: Theme.of(context).textTheme.subtitle1,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

          ],
        );
      },
    );
  }


  Future<void> submittedAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Action completed.',style: Theme.of(context).textTheme.subtitle1,),
          // content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            FlatButton(
              child: Text('Close',style: Theme.of(context).textTheme.subtitle1,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  deleteNotificationsAlert(BuildContext context, String uid) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to clear all notifications?',style: Theme.of(context).textTheme.subtitle1,),
          content: Text('Join requests and follow requests will also be removed.',style: Theme.of(context).textTheme.subtitle1,),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                CloudFunction().removeAllNotifications();
                // DatabaseService(uid: uid).removeAllNotificationData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> leaveTripAlert(BuildContext context,String uid, Trip tripDetails) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Are you sure you want to leave this Trip?',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          content: Text('You will no longer have access to this Trip',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDetails.documentId, uid,tripDetails.ispublic);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      Wrapper(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('No',style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTripAlert(BuildContext context, Trip tripDetails) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete this trip?',style: Theme.of(context).textTheme.subtitle1,),
          content: Text(
            'All data associated with this trip will be deleted.',style: Theme.of(context).textTheme.subtitle1,),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                CloudFunction().deleteTrip(tripDetails.documentId, tripDetails.ispublic);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      Wrapper(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }

  Future<void> convertTripAlert(BuildContext context, Trip tripDetails) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: tripDetails.ispublic
              ? Text(
            'Are you sure you want to convert this into a Private Trip?',style: Theme.of(context).textTheme.subtitle1,)
              : Text(
            'Are you sure you want to convert this into a Public Trip?',style: Theme.of(context).textTheme.subtitle1,),
          content: tripDetails.ispublic
              ? Text('This trip will only be visible to members.',style: Theme.of(context).textTheme.subtitle1,)
              : Text('Trip will be become public for followers to see.',style: Theme.of(context).textTheme.subtitle1,),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                DatabaseService().convertTrip(tripDetails);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      Wrapper(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeMemberAlert(BuildContext context, Trip tripDetails, Members member) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove ${member.firstName+' '+ member.lastName}?',style: Theme.of(context).textTheme.subtitle1,),
          content: Text(
            '${member.firstName} will no longer be able to view this trip.',style: Theme.of(context).textTheme.subtitle1,),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDetails.documentId, member.uid, tripDetails.ispublic);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void showRequestDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Request Submitted. Once accepted by owner this trip will appear under "My Crew"')));
  }

  void unblockDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('User has been unblocked.')));
  }

  Future<void> submitFeedbackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback Submitted!'),
          content: const Text(
              'We thank you for your feedback.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.pop(context);
                // Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> followBackAlert(BuildContext context, String userUID) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Follow back?',style: Theme.of(context).textTheme.subtitle1,)),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                CloudFunction().followBack(userUID);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}