import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/menu_screens/help/report.dart';
import 'package:travelcrew/services/auth/auth.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/navigation/router.dart';

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
          title: Text('Block Account',textScaleFactor: 1.5,),
          content: Text(
              blockMessage,),
          actions: <Widget>[
            TextButton(
              child: const Text('Block',),
              onPressed: () {
                CloudFunction().blockUser(blockedUserID);
                navigationService.pop();
                submittedAlert(context);
              },
            ),
            TextButton(
              child: const Text('Cancel',),
              onPressed: () {
                navigationService.pop();
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
          title: Text('Report',textScaleFactor: 1.5,),
          content: Text(
              reportMessage,style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('Report',),
              onPressed: () {
                navigationService.pop();
                navigationService.navigateTo(ReportContentRoute,arguments: ReportArguments(type, userProfile, activityData, tripDetails, lodgingData));
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ReportContent(type: type, tripDetails: tripDetails, userAccount: userProfile, activity: activityData, lodging: lodgingData,)),
                // );
              },
            ),
            TextButton(
              child: const Text('Cancel',),
              onPressed: () {
                navigationService.pop();
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
          title: const Text(
              'Action completed.',),
          // content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close',),
              onPressed: () {
                navigationService.pop();
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
          title: const Text('Clear all notifications?',textScaleFactor: 1.2,),
          content: const Text('Join requests and follow requests will also be removed.',),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().removeAllNotifications();
                // DatabaseService(uid: uid).removeAllNotificationData();
                navigationService.pop();
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
          title: const Text(
              'Are you sure you want to leave this Trip?',textScaleFactor: 1.2,),
          content: const Text('You will no longer have access to this Trip',),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes',),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDetails.documentId, uid,tripDetails.ispublic);
                navigationService.pushNamedAndRemoveUntil(WrapperRoute);
              },
            ),
            TextButton(
              child: const Text('No',),
              onPressed: () {
                navigationService.pop();
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
          title: const Text('Are you sure you want to delete this trip?',textScaleFactor: 1.2,),
          content: const Text(
            'All data associated with this trip will be deleted.',),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().deleteTrip(tripDetails.documentId, tripDetails.ispublic);
                navigationService.pushNamedAndRemoveUntil(WrapperRoute);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
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
              ? const Text(
            'Convert to Private Trip?',textScaleFactor: 1.2,)
              : const Text(
            'Convert to Public Trip?',),
          content: tripDetails.ispublic
              ? const Text('This trip will only be visible to members.')
              : const Text('Trip will be become public for followers to see.',),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                DatabaseService().convertTrip(tripDetails);
                navigationService.pushNamedAndRemoveUntil(WrapperRoute);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeMemberAlert(BuildContext context, Trip tripDetails, UserPublicProfile member) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove ${member.firstName+' '+ member.lastName}?',textScaleFactor: 1.5,),
          content: Text(
            '${member.firstName} will no longer be able to view this trip.',),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDetails.documentId, member.uid, tripDetails.ispublic);
                navigationService.pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }
  void showRequestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Request Submitted. Once accepted by owner this trip will appear under "My Crew"')));
  }
  void copiedToClipboardDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Copied to Clipboard.')));
  }

  void unblockDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('User has been unblocked.')));
  }

  followRequestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Request sent.')));
  }

  newMessageDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> submitFeedbackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  const Text('Feedback Submitted!',textScaleFactor: 1.5,),
          content:  const Text(
              'We thank you for your feedback.'),
          actions: <Widget>[
            TextButton(
              child:  Text('Close'),
              onPressed: () {
                navigationService.pop();
                // Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addTripAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  const Text('Trip Created!',textScaleFactor: 1.5,),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                navigationService.pop();
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
          title: Center(child: const Text('Follow back?',textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().followBack(userUID);
                navigationService.pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  //Finalize option
  Future<void> finalizeOptionAlert(BuildContext context, String fieldID) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Finalize this option?',textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {

                navigationService.pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  //Unfollow alert dialog
  Future<void> unFollowAlert(BuildContext context, String userUID) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Unfollow?',textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                CloudFunction().unFollowUser(userUID);
                navigationService.pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                navigationService.pop();
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
      builder: (BuildContext context) {
      return _SystemPadding(
        child: AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            'Reset Password',
            textAlign: TextAlign.center,
            textScaleFactor: 1.5,
          ),
          content: Row(
            children: <Widget>[
              Expanded(
                child: Builder(
                  builder: (context) => Form(
                    key: _formKey,
                    child: TextFormField(
                      maxLines: 1,
                      autofocus: true,
                      onSaved: (val) {
                        email = val;
                      },
                      validator: (value) {
                        if (value.isEmpty || !value.contains('.com')) {
                          return 'Please enter valid email address.';
                        } else {
                          return null;
                        }
                      },
                      decoration:
                          InputDecoration(hintText: 'Your email address'),
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  navigationService.pop();
                }),
            TextButton(
                child: const Text('Reset'),
                onPressed: () {
                  final form = _formKey.currentState;
                  if (form.validate()) {
                    form.save();
                    AuthService().resetPassword(email);
                    submittedAlert(context);
                    navigationService.pop();
                  }
                })
          ],
        ),
      );
    });
  }

  Future<void> suggestionPageAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Please make sure location settings are enabled to continue.',textScaleFactor: 1.2,),
          // content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            TextButton(
              child: Text('Close',style: Theme.of(context).textTheme.subtitle1,),
              onPressed: () {
                navigationService.pop();
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
          title: Center(child: const Text('Delete?',textScaleFactor: 1.5,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  CloudFunction().deleteTransportation(tripDocID: transportationData.tripDocID,fieldID: transportationData.fieldID);
                  navigationService.pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  navigationService.pop();
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
          title: Center(child: const Text('Delete?',textScaleFactor: 1.5,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  CloudFunction().removeItemFromBringingList(tripDocID, itemID);
                  navigationService.pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  navigationService.pop();
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