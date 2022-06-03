import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/authentication_bloc/authentication_event.dart';
import '../../models/activity_model.dart';
import '../../models/custom_objects.dart';
import '../../models/lodging_model.dart';
import '../../models/transportation_model.dart';
import '../../models/trip_model.dart';
import '../../repositories/user_repository.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/navigation/router.dart';

/// All alert dialogs
class TravelCrewAlertDialogs {
  var userService = locator<UserService>();


  Future<void> disableAccount(BuildContext context,) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Delete Account'),textScaleFactor: 1.5,),
          content: Text(
            deleteAccountMessage(),),
          actions: <Widget>[
            TextButton(
              child: Text(cancelMessage()),
              onPressed: () {
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(Intl.message('Confirm Delete'),),
              onPressed: () async {
                await navigationService.pop();
                BlocProvider.of<AuthenticationBloc>(context)
                    .add(AuthenticationLoggedOut());
                CloudFunction().disableAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> blockAlert(BuildContext context, String blockedUserID) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Block Account'),textScaleFactor: 1.5,),
          content: Text(
              blockMessage(),),
          actions: <Widget>[
            TextButton(
              child: Text(Intl.message('Block'),),
              onPressed: () {
                CloudFunction().blockUser(blockedUserID);
                navigationService.pop();
                submittedAlert(context);
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> reportAlert({required BuildContext context, Trip? tripDetails, required UserPublicProfile userProfile, ActivityData? activityData, LodgingData? lodgingData, required String type}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(report(),textScaleFactor: 1.5,),
          content: Text(
              reportMessage(),style: TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: Text(report(),),
              onPressed: () {
                navigationService.pop();
                navigationService.navigateTo(ReportContentRoute,arguments: ReportArguments(type, userProfile, activityData, tripDetails, lodgingData));
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message
              ('Action completed.'),),
          actions: <Widget>[
            TextButton(
              child: Text(closeMessage(),),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> turnNotificationsOff(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Disable Notifications?'),textAlign: TextAlign.center,),
          content: Text(Intl.message
            ('Please go to your device settings to disable notifications.'),textAlign: TextAlign.center,),
          actions: <Widget>[
            TextButton(
              child: Text(closeMessage(),),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Clear all notifications?'),textScaleFactor: 1.2,),
          content: Text(Intl.message('Join requests and follow requests will also be removed.'),),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(yesMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message
              ('Are you sure you want to leave this Trip?'),textScaleFactor: 1.2,),
          content: Text(Intl.message('You will no longer have access to this Trip'),),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage(),),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDocID: tripDetails.documentId!, userUID: uid, ispublic: tripDetails.ispublic);
                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
              },
            ),
            TextButton(
              child: Text(noMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Are you sure you want to delete this trip?'),textScaleFactor: 1.2,),
          content: Text(Intl.message
            ('All data associated with this trip will be deleted.'),),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage()),
              onPressed: () {
                CloudFunction().deleteTrip(tripDetails.documentId!, tripDetails.ispublic);
                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: tripDetails.ispublic
              ? Text(Intl.message
            ('Convert to Private Trip?'),textScaleFactor: 1.2,)
              : Text(Intl.message
            ('Convert to Public Trip?'),),
          content: tripDetails.ispublic
              ? Text(Intl.message('This trip will only be visible to members.'))
              : Text(Intl.message('Trip will be become public for followers to see.'),),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage()),
              onPressed: () {
                DatabaseService().convertTrip(tripDetails);
                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> removeMemberAlert(BuildContext context, Trip tripDetails, UserPublicProfile? member) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(
            Intl.message('Remove ${member?.displayName}?'),
            textScaleFactor: 1.5,),
          content: Text(Intl.message(
              '${member?.displayName} will no longer be able to view this trip.'),),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage()),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDocID: tripDetails.documentId!, userUID: member!.uid!, ispublic: tripDetails.ispublic);
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void invitationDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Invitation sent.'))));
  }
  void showRequestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Request Submitted. Once accepted by owner this trip will appear under "My Crew"'))));
  }
  void copiedToClipboardDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Copied to Clipboard.'))));
  }

  void unblockDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('User has been unblocked.'))));
  }

  followRequestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Request sent.'))));
  }

  newMessageDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  newTripErrorDialog(BuildContext context,) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Unable to create trip at this time.'))));
  }

  Future<void> submitFeedbackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Feedback Submitted!'),textScaleFactor: 1.5,),
          content: Text(Intl.message(
              'We thank you for your feedback.')),
          actions: <Widget>[
            TextButton(
              child:  Text(closeMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title:  Text(Intl.message('Trip Created!'),textScaleFactor: 1.5,),
          actions: <Widget>[
            TextButton(
              child: Text(closeMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message('Notification Sent!')),
        );
      },
    );
  }

  Future<void> followBackAlert(BuildContext context, String userUID) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(Intl.message('Follow back?'),textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage()),
              onPressed: () {
                CloudFunction().followBack(userUID);
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(Intl.message('Finalize?'),textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage()),
              onPressed: () {

                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(Intl.message('Unfollow?'),textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: Text(yesMessage()),
              onPressed: () {
                CloudFunction().unFollowUser(userUID);
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(cancelMessage()),
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
    String? email;
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
      return _SystemPadding(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(Intl.message
            ('Reset Password'),
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
                        if ((value?.isEmpty ?? true) || !value!.contains('.com')) {
                          return Intl.message('Please enter valid email address.');
                        } else {
                          return null;
                        }
                      },
                      decoration:
                          InputDecoration(hintText: Intl.message('Your email address')),
                    ),
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
                child: Text(cancelMessage()),
                onPressed: () {
                  navigationService.pop();
                }),
            TextButton(
                child: Text(Intl.message('Reset')),
                onPressed: () {
                  final FormState? form = _formKey.currentState;
                  if (form!.validate()) {
                    form.save();
                    UserRepository().resetPassword(email!);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message
            ('Please make sure location settings are enabled to continue.'),textScaleFactor: 1.2,),
          // content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            TextButton(
              child: Text(closeMessage(),style: Theme.of(context).textTheme.subtitle1,),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: const Text('Delete?',textScaleFactor: 1.5,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: Text(yesMessage()),
                onPressed: () {
                  CloudFunction().deleteTransportation(tripDocID: transportationData.tripDocID,fieldID: transportationData.fieldID);
                  navigationService.pop();
                },
              ),
              TextButton(
                child: Text(cancelMessage()),
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

  Future<void> deleteBringingItemAlert(BuildContext context, String tripDocID, String itemID) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(deleteMessage(),textScaleFactor: 1.5,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: Text(yesMessage()),
                onPressed: () {
                  CloudFunction().removeItemFromBringingList(tripDocID, itemID);
                  navigationService.pop();
                },
              ),
              TextButton(
                child: Text(cancelMessage()),
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
  final Widget? child;

  _SystemPadding({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}

