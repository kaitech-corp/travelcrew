import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/menu_screens/help/report.dart';
import 'package:travelcrew/services/auth.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';

class TravelCrewAlertDialogs {
  var userService = locator<UserService>();

  var reportMessage = "Submit a report and we will review this report within 24 hrs and "
      "if deemed inappropriate we will take action by removing the "
      "content and/or account within that time frame.";

  var blockMessage = 'This user will be removed from all of your trips (public and private) and '
      ' will not be able to view any of your content. Please note this user will not be removed from '
      'shared trips where neither party is the owner. It is your responsibility to exit such trips.';

  var forgotPassword = "We'll send you an email with instructions to reset your password.";

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
  Future<void> reportAlert({BuildContext context, Trip tripDetails, UserPublicProfile userProfile, ActivityData activityData, LodgingData lodgingData, String type}) {
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

  deleteNotificationsAlert(BuildContext context,) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to clear all notifications?',style: Theme.of(context).textTheme.subtitle1,),
          content: Text('Join requests and follow requests will also be removed.',style: Theme.of(context).textTheme.subtitle1,),
          actions: <Widget>[
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Yes'),
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
                Navigator.pushNamed(context, '/wrapper');
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
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().deleteTrip(tripDetails.documentId, tripDetails.ispublic);
                Navigator.pushNamed(context, '/wrapper');
              },
            ),
            FlatButton(
              child: const Text('No'),
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
                Navigator.pushNamed(context, '/wrapper');
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
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDetails.documentId, member.uid, tripDetails.ispublic);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('No'),
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
        .showSnackBar(SnackBar(content: const Text('User has been unblocked.')));
  }

  Future<void> submitFeedbackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedback Submitted!'),
          content: const Text(
              'We thank you for your feedback.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Close'),
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

  Future<void> pushCustomNotification(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Sent!'),
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
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().followBack(userUID);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> resetPasswordDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    String email;
    return await showDialog<String>(
      context: context,
      child: _SystemPadding(child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        title: const Text('Reset Password', textAlign: TextAlign.center,),
        content:  Row(
          children: <Widget>[
             Expanded(
              child:  Builder(
                builder: (context) => Form(
                  key: _formKey,
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: true,
                    onSaved: (val){
                      email = val;
                    },
                    validator: (value) {
                      if (value.isEmpty || !value.contains('.com')) {
                        return 'Please enter valid email address.';
                      } else {
                        return null;
                      }
                    },
                    decoration:  const InputDecoration(
                         hintText: 'Your email address'),
                  ),
                ),
              ),
            )
          ],
        ),
        actions: <Widget>[
           FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }),
           FlatButton(
              child: const Text('Reset'),
              onPressed: () {
                final form = _formKey.currentState;
                if (form.validate()){
                  form.save();
                  AuthService().resetPassword(email);
                  submittedAlert(context);
                  Navigator.pop(context);
                }
              })
        ],
      ),),
    );
  }

  Future<void> SuggestionPageAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Please make sure location settings are enabled to continue.',style: Theme.of(context).textTheme.subtitle1,),
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

  Future<void> deleteTransportationAlert(BuildContext context, TransportationData transportationData) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Delete?',style: Theme.of(context).textTheme.subtitle1,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                child: const Text('Yes'),
                onPressed: () {
                  CloudFunction().deleteTransportation(tripDocID: transportationData.tripDocID,fieldID: transportationData.fieldID);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteBringinItemAlert(BuildContext context, String tripDocID, String itemID) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Delete?',style: Theme.of(context).textTheme.subtitle1,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                child: const Text('Yes'),
                onPressed: () {
                  CloudFunction().removeItemFromBringingList(tripDocID, itemID);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}