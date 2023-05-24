import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/authentication_bloc/authentication_event.dart';

import '../../models/activity_model/activity_model.dart';
import '../../models/lodging_model/lodging_model.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import '../../models/transportation_model/transportation_model.dart';
import '../../models/trip_model/trip_model.dart';
import '../../repositories/user_repository.dart';
import '../../services/constants/constants.dart';
import '../../services/database.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/navigation/router.dart';
import '../../services/theme/text_styles.dart';
import '../Trip_Management/logic/logic.dart';

/// All alert dialogs
class TravelCrewAlertDialogs {
  UserService userService = locator<UserService>();


  Future<void> disableAccount(BuildContext context,) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.deleteAccount,textScaleFactor: 1.5,),
          content: Text(
            deleteAccountMessage(),),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
              onPressed: () {
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirmDelete,),
              onPressed: () async {
                navigationService.pop();
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.blockAccount,textScaleFactor: 1.5,),
          content: Text(
            AppLocalizations.of(context)!.blockMessage,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.block,),
              onPressed: () {
                CloudFunction().blockUser(blockedUserID);
                navigationService.pop();
                submittedAlert(context);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> reportAlert({required BuildContext context, Trip? tripDetails, UserPublicProfile? userProfile, ActivityModel? activityData, LodgingModel? lodgingData, required String type}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.report,textScaleFactor: 1.5,),
          content: Text(
              reportMessage(),style: const TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.report,),
              onPressed: () {
                navigationService.pop();
                navigationService.navigateTo(ReportContentRoute,arguments: ReportArguments(type, userProfile ?? UserPublicProfile.mock(), activityData, tripDetails, lodgingData));
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.actionCompleted,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.closeMessage,),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.disableNotifications,textAlign: TextAlign.center,),
          content: Text(AppLocalizations.of(context)!.notificationMessage,textAlign: TextAlign.center,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.closeMessage,),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> deleteNotificationsAlert(BuildContext context,) {

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.clearNotifications,textScaleFactor: 1.2,),
          content: Text(AppLocalizations.of(context)!.clearNotificationMessage,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.noMessage),
              onPressed: () {
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.leaveTrip,textScaleFactor: 1.2,),
          content: Text(AppLocalizations.of(context)!.leaveTripMessage,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage,),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDocID: tripDetails.documentId, userUID: uid, ispublic: tripDetails.ispublic);
                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.noMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(AppLocalizations.of(context)!.deleteTrip,textScaleFactor: 1.2,),
          content: Text(AppLocalizations.of(context)!.deleteTripMessage,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
              onPressed: () {
                CloudFunction().deleteTrip(tripDetails.documentId, tripDetails.ispublic);
                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: tripDetails.ispublic
              ? Text(AppLocalizations.of(context)!.convertToPrivateTrip,textScaleFactor: 1.2,)
              : Text(AppLocalizations.of(context)!.convertToPublicTrip,),
          content: tripDetails.ispublic
              ? Text(AppLocalizations.of(context)!.convertToPrivateTripMessage)
              : Text(AppLocalizations.of(context)!.convertToPublicTripMessage,),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
              onPressed: () {
                convertTrip(tripDetails);
                navigationService.pushNamedAndRemoveUntil(LaunchIconBadgerRoute);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('${AppLocalizations.of(context)!.remove} ${member?.displayName}?',
            textScaleFactor: 1.5,),
          content: Text('${member?.displayName} ${AppLocalizations.of(context)!.removeMessage}'),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
              onPressed: () {
                CloudFunction().leaveAndRemoveMemberFromTrip(tripDocID: tripDetails.documentId, userUID: member!.uid, ispublic: tripDetails.ispublic);
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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

  void followRequestDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Request sent.'))));
  }

  void newMessageDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void newTripErrorDialog(BuildContext context,) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Intl.message('Unable to create trip at this time.'))));
  }

  Future<void> submitFeedbackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(Intl.message('Follow back?'),textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
              onPressed: () {
                CloudFunction().followBack(userUID);
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(Intl.message('Finalize?'),textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
              onPressed: () {

                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(Intl.message('Unfollow?'),textScaleFactor: 1.5,)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesMessage),
              onPressed: () {
                CloudFunction().unFollowUser(userUID);
                navigationService.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancelMessage),
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
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? email;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
      return _SystemPadding(
        child: AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
                  builder: (BuildContext context) => Form(
                    key: formKey,
                    child: TextFormField(
                      autofocus: true,
                      onSaved: (String? val) {
                        email = val;
                      },
                      validator: (String? value) {
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
                child: Text(AppLocalizations.of(context)!.cancelMessage),
                onPressed: () {
                  navigationService.pop();
                }),
            TextButton(
                child: Text(Intl.message('Reset')),
                onPressed: () {
                  final FormState? form = formKey.currentState;
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(Intl.message
            ('Please make sure location settings are enabled to continue.'),textScaleFactor: 1.2,),
          // content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            TextButton(
              child: Text(closeMessage(),style: titleMedium(context),),
              onPressed: () {
                navigationService.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTransportationAlert(BuildContext context, TransportationModel transportationData) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: const Center(child: Text('Delete?',textScaleFactor: 1.5,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.yesMessage),
                onPressed: () {
                  CloudFunction().deleteTransportation(tripDocID: transportationData.tripDocID,fieldID: transportationData.fieldID);
                  navigationService.pop();
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancelMessage),
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
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Center(child: Text(deleteMessage(),textScaleFactor: 1.5,)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                child: Text(AppLocalizations.of(context)!.yesMessage),
                onPressed: () {
                  CloudFunction().removeItemFromBringingList(tripDocID, itemID);
                  navigationService.pop();
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancelMessage),
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

  const _SystemPadding({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
