import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/cost_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../models/trip_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';

ValueNotifier<List<String>> selectedList;

/// Split Package for all split functions
class SplitPackage {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  /// Logic to split evenly among all members in the trip.
  double standardSplit(int userCount, double itemTotal) {
    double evenSplitAmount = 0;
    if (userCount != null && userCount > 0) {
      return evenSplitAmount = itemTotal / userCount;
    } else {
      return evenSplitAmount;
    }
  }

  /// Sum up outstanding balance
  double sumRemainingBalance(List<CostObject> coList) {
    double total = 0;
    coList.forEach((element) =>
        total = total + ((element.paid == false) ? element.amountOwe : 0));
    return total;
  }

  /// Split item alert which checks if item has already been split.
  Future<void> splitItemAlert(BuildContext context, SplitObject splitObject,
      {Trip trip}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<bool>(
          builder: (context, response) {
            if (response.hasData && response.data == true) {
              return AlertDialog(
                title: Text(
                  '${splitObject.itemName} has already been split.',
                  textScaleFactor: 1.5,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return AlertDialog(
                title: Text(
                  'Split ${splitObject.itemName}?',
                  textScaleFactor: 1.5,
                  textAlign: TextAlign.center,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      navigationService.pop();
                      splitDialog(context, splitObject, trip: trip);
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      navigationService.pop();
                    },
                    child: const Text('No'),
                  ),
                ],
              );
            }
          },
          future: DatabaseService(tripDocID: trip.documentId)
              .checkSplitItemExist(splitObject.itemDocID),
        );
      },
    );
  }

  /// Logic for icon button to check it item has been split
  /// and directs the user accordingly.
  Widget splitItemExist(BuildContext context, SplitObject splitObject,
      {Trip trip}) {
    return FutureBuilder<bool>(
      builder: (BuildContext context, response) {
        if (response.hasData && response.data == false) {
          return IconButton(
              visualDensity: const VisualDensity(vertical: -4),
              icon: const IconThemeWidget(
                icon: Icons.monetization_on_outlined,
              ),
              onPressed: () {
                splitDialog(context, splitObject, trip: trip);
              });
        } else {
          return IconButton(
              visualDensity: const VisualDensity(vertical: -4),
              icon: const IconThemeWidget(
                icon: Icons.monetization_on,
              ),
              onPressed: () {});
        }
      },
      future: DatabaseService(tripDocID: trip.documentId)
          .checkSplitItemExist(splitObject.itemDocID),
    );
  }

  /// Popup dialog to create split item.
  Future<Widget> splitDialog(BuildContext context, SplitObject splitObject,
      {Trip trip}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                'Split',
                style: Theme.of(context).textTheme.subtitle1,
                textScaleFactor: 1.5,
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                height: SizeConfig.screenHeight * .5,
                width: SizeConfig.screenWidth * .75,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(
                        splitObject.itemName,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                            builder: (BuildContext context) => Form(
                                key: _formKey,
                                child: TextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    enableInteractiveSelection: true,
                                    decoration: InputDecoration(
                                        labelText: 'Total',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ReusableThemeColor()
                                                  .colorOpposite(context)),
                                        )),
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter an amount.';
                                        // ignore: missing_return
                                      }
                                    },
                                    onChanged: (val) => {
                                          splitObject.itemTotal =
                                              double.parse(val),
                                        }))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            )),
                          ),
                          onPressed: () {
                            final form = _formKey.currentState;
                            form.save();
                            if (form.validate()) {
                              try {
                                splitObject.dateCreated = Timestamp.now();
                                splitObject.lastUpdated = Timestamp.now();
                                splitObject.purchasedByUID =
                                    userService.currentUserID;
                                splitObject.userSelectedList = trip.accessUsers
                                    .where((user) =>
                                        !selectedList.value.contains(user))
                                    .toList();
                                splitObject.amountRemaining =
                                    splitObject.itemTotal -
                                        standardSplit(
                                            splitObject.userSelectedList.length,
                                            splitObject.itemTotal);
                              } catch (e) {
                                CloudFunction().logError(
                                    'Tried saving splitObject data: $e');
                              }
                              DatabaseService().createSplitItem(splitObject);
                              navigationService.pop();
                            }
                          },
                          child: Text(
                            'Split evenly',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: SizeConfig.screenHeight * .3,
                          width: double.infinity,
                          child: SplitMembersLayout(
                            tripDetails: trip,
                          )),
                    ],
                  ),
                ),
              ));
        });
  }

  /// Edit Split Dialog
  Future<Widget> editSplitDialog(BuildContext context, SplitObject splitObject,
      {Trip trip}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                'Split',
                style: Theme.of(context).textTheme.subtitle1,
                textScaleFactor: 1.5,
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                height: SizeConfig.screenHeight * .2,
                width: SizeConfig.screenWidth * .75,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        splitObject.itemName,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                            builder: (BuildContext context) => Form(
                                key: _formKey2,
                                child: TextFormField(
                                    initialValue:
                                        splitObject.itemTotal.toString(),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: InputDecoration(
                                        labelText: 'Total',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: ReusableThemeColor()
                                                  .colorOpposite(context)),
                                        )),
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter an amount.';
                                        // ignore: missing_return
                                      }
                                    },
                                    onChanged: (val) => {
                                          splitObject.itemTotal =
                                              double.parse(val),
                                        }))),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                              ),
                              onPressed: () {
                                final FormState form = _formKey2.currentState;
                                form.save();
                                if (form.validate()) {
                                  splitObject.lastUpdated = Timestamp.now();
                                  DatabaseService()
                                      .createSplitItem(splitObject);
                                  navigationService.pop();
                                }
                              },
                              child: Text(
                                'Save',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                )),
                              ),
                              onPressed: () {
                                DatabaseService()
                                    .deleteSplitObject(splitObject);
                                navigationService.pop();
                              },
                              child: Text(
                                'Delete',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }
}

class SplitMembersLayout extends StatefulWidget {
  final Trip tripDetails;
  final String ownerID;

  SplitMembersLayout({Key key, this.tripDetails, this.ownerID})
      : super(key: key);

  @override
  _SplitMembersLayoutState createState() => _SplitMembersLayoutState();
}

class _SplitMembersLayoutState extends State<SplitMembersLayout> {
  var _showImage = false;
  String _image;

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    selectedList = ValueNotifier([]);
    super.initState();
  }

  @override
  void dispose() {
    selectedList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getMember(context, widget.tripDetails);
  }

  Widget getMember(BuildContext context, Trip tripDetails) {
    return Stack(
      children: [
        StreamBuilder(
          builder: (BuildContext context, userData) {
            if (userData.hasError) {
              CloudFunction()
                  .logError('Error streaming user data for '
                  'members layout: ${userData.error.toString()}');
            }
            if (userData.hasData) {
              final List<UserPublicProfile> crew = userData.data;
              return ListView.builder(
                itemCount: crew.length,
                itemBuilder: (BuildContext context, int index) {
                  final UserPublicProfile member = crew[index];
                  return userCard(context, member, tripDetails);
                },
              );
            } else {
              return Loading();
            }
          },
          stream: DatabaseService().getcrewList(widget.tripDetails.accessUsers),
        ),
        if (_showImage) ...[
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          Center(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: _image.isNotEmpty
                    ? Image.network(
                        _image,
                        height: 300,
                        width: 300,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        profileImagePlaceholder,
                        height: 300,
                        width: 300,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget userCard(
      BuildContext context, UserPublicProfile member, Trip tripDetails) {
    return Card(
      key: Key(member.uid),
      color: Colors.white,
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _showImage = true;
            _image = member.urlToImage;
          });
        },
        onLongPressEnd: (LongPressEndDetails details) {
          setState(() {
            _showImage = false;
          });
        },
        onTap: () {
          navigationService.navigateTo(UserProfilePageRoute,
              arguments: member);
        },
        child: CheckboxListTile(
          value: !selectedList.value.contains(member.uid),
          onChanged: (bool value) {
            setState(() {
              if (value) {
                selectedList.value.remove(member.uid);
              } else {
                selectedList.value.add(member.uid);
              }
            });
          },
          secondary: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.blue,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: member.urlToImage.isNotEmpty
                  ? Image.network(
                      member.urlToImage,
                      height: 75,
                      width: 75,
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
          ),
          title: Text(
            member.displayName,
            style: Theme.of(context).textTheme.subtitle2,
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
