import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelcrew/models/cost_model.dart';
import 'package:travelcrew/models/split_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/explore/members/members_layout.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/size_config/size_config.dart';



ValueNotifier<List<String>> selectedList;

class SplitPackage {

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  /// Logic to split evenly among all members in the trip.
  double standardSplit(int userCount, double itemTotal) {
    double evenSplitAmount = 0;
    if (userCount != null && userCount > 0) {
      evenSplitAmount = itemTotal / userCount;
      return evenSplitAmount;
    } else {
      return evenSplitAmount;
    }
  }

  /// Sum up outstanding balance
  double sumRemainingBalance(List<CostObject> coList){
    double total = 0;
    coList.forEach((element) => total=total+((element.paid == false) ? element.amountOwe : 0));
    return total;
  }
  /// Split item alert which checks if item has already been split.
  Future<void> splitItemAlert(BuildContext context, SplitObject splitObject, {Trip trip}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
              builder: (context, response){
                if(response.hasData && response.data == true){
                  return AlertDialog(
                      title: Text('${splitObject.itemName} has already been split.',textScaleFactor: 1.5,textAlign: TextAlign.center,),
                  );
                } else {
                  return AlertDialog(
                    title: Text('Split ${splitObject.itemName}?',textScaleFactor: 1.5,textAlign: TextAlign.center,),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          navigationService.pop();
                          splitDialog(context,splitObject,trip: trip);
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
                }
              },
              future: DatabaseService(tripDocID: trip.documentId).checkSplitItemExist(splitObject.itemDocID),
            );
      },
    );
  }

  /// Logic for icon button to check it item has been split and directs the user accordingly.
  Widget splitItemExist(BuildContext context, SplitObject splitObject, {Trip trip}){
     return FutureBuilder(
        builder: (context, response){
          if(response.hasData && response.data == false){
            return IconButton(
                icon: IconThemeWidget(icon: Icons.monetization_on_outlined,),
                onPressed: (){
                  splitDialog(context,splitObject,trip: trip);
                });
          } else {
            return IconButton(
                icon: IconThemeWidget(icon: Icons.monetization_on,),
                onPressed: (){
                  navigationService.navigateTo(CostPageRoute,arguments: trip);
                });
          }
        },
      future: DatabaseService(tripDocID: trip.documentId).checkSplitItemExist(splitObject.itemDocID),
        );
  }
/// Popup dialog to create split item.
  Future splitDialog(BuildContext context, SplitObject splitObject, {Trip trip}) async {

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Split',style: Theme.of(context).textTheme.subtitle1,textScaleFactor: 1.5,textAlign: TextAlign.center,),
            content: Container(
              height: SizeConfig.screenHeight*.5,
              width: SizeConfig.screenWidth*.75,
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(splitObject.itemName, style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                          builder: (context) => Form(
                              key: _formKey,
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  enableInteractiveSelection: true,
                                  decoration:
                                  InputDecoration(
                                      labelText: 'Total',
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                                      )
                                  ),
                                  // ignore: missing_return
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter an amount.';
                                      // ignore: missing_return
                                    }
                                  },
                                  onChanged: (val) =>
                                  {
                                    splitObject.itemTotal = double.parse(val),

                                  }
                              )
                          )
                        ),
                      ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )
                                ),
                              ),
                              child: Text('Split evenly',style: Theme.of(context).textTheme.subtitle1,),
                              onPressed: (){
                                final form = _formKey.currentState;
                                form.save();
                                if (form.validate()) {
                                  try {
                                    splitObject.dateCreated = Timestamp.now();
                                    splitObject.lastUpdated = Timestamp.now();
                                    splitObject.purchasedByUID =
                                        userService.currentUserID;
                                    splitObject.userSelectedList = trip
                                        .accessUsers
                                        .where((user) =>
                                            !selectedList.value.contains(user))
                                        .toList();
                                    splitObject.amountRemaining = splitObject
                                            .itemTotal -
                                        standardSplit(
                                            splitObject.userSelectedList.length,
                                            splitObject.itemTotal);
                                  } catch (e) {
                                    CloudFunction().logError(
                                        'Tried saving splitObject data: $e');
                                  }

                                  DatabaseService()
                                      .createSplitItem(splitObject);
                                  navigationService.pop();
                                  navigationService.navigateTo(CostPageRoute,
                                      arguments: trip);
                                }
                              },
                            ),
                          ),
                      Container(
                        height: SizeConfig.screenHeight*.3,
                          width: double.infinity,
                          child: MembersLayout(tripDetails: trip,)),
                    ],
                  ),
                ),
            )
          );
        }
    );
  }

  /// Edit Split Dialog
  Future editSplitDialog(BuildContext context, SplitObject splitObject, {Trip trip}) async {

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Split',style: Theme.of(context).textTheme.subtitle1,textScaleFactor: 1.5,textAlign: TextAlign.center,),
              content: Container(
                height: SizeConfig.screenHeight*.2,
                width: SizeConfig.screenWidth*.75,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(splitObject.itemName, style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                            builder: (context) => Form(
                                key: _formKey2,
                                child: TextFormField(
                                  initialValue: splitObject.itemTotal.toString(),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    enableInteractiveSelection: true,
                                    decoration:
                                    InputDecoration(
                                        labelText: 'Total',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: ReusableThemeColor().colorOpposite(context)),
                                        )
                                    ),
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please enter an amount.';
                                        // ignore: missing_return
                                      }
                                    },
                                    onChanged: (val) =>
                                    {
                                      splitObject.itemTotal = double.parse(val),
                                    }
                                )
                            )
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )
                                ),
                              ),
                              child: Text('Save',style: Theme.of(context).textTheme.subtitle1,),
                              onPressed: (){
                                final form = _formKey2.currentState;
                                form.save();
                                if (form.validate()) {
                                  splitObject.lastUpdated = Timestamp.now();
                                  DatabaseService().createSplitItem(splitObject);
                                  navigationService.pop();
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    )
                                ),
                              ),
                              child: Text('Delete',style: Theme.of(context).textTheme.subtitle1,),
                              onPressed: (){
                                  DatabaseService().deleteSplitObject(splitObject);
                                  navigationService.pop();

                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          );
        }
    );
  }
}