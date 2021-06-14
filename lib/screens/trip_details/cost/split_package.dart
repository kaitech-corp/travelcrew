import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

class SplitObject {
  double amountRemaining;
  Timestamp dateCreated;
  String details;
  String itemDescription;
  String itemDocID;
  String itemName;
  double itemTotal;
  String itemType;
  Timestamp lastUpdated;
  String purchasedByUID;
  String tripDocID;
  List<String> users;
  List<String> userSelectedList;

  SplitObject({
      this.amountRemaining,
      this.dateCreated,
      this.details,
      this.itemDescription,
      this.itemDocID,
      this.itemName,
      this.itemTotal,
      this.itemType,
      this.lastUpdated,
      this.purchasedByUID,
      this.tripDocID,
      this.users,
      this.userSelectedList});



  SplitObject.fromData(Map<String, dynamic> data):
      amountRemaining = data['amountRemaining'] ?? '',
        dateCreated = data['dateCreated'] ?? '',
        details = data['details'] ?? '',
        itemDescription = data['itemDescription'] ?? '',
        itemDocID = data['itemDocID'] ?? '',
        itemName = data['itemName'] ?? '',
        itemTotal = data['itemTotal'] ?? '',
        itemType = data['itemType'] ?? '',
        lastUpdated = data['lastUpdated'] ?? '',
        purchasedByUID = data['purchasedByUID'] ?? '',
        users = List.from(data['users']) ?? [],
        userSelectedList = List.from(data['userSelectedList']) ?? [],
        tripDocID = data['tripDocID'] ?? '';

  Map<String, dynamic> toJson(){
    return {
      'amountRemaining':amountRemaining,
      'dateCreated':dateCreated,
      'details':details,
      'itemDescription':itemDescription,
      'itemDocID':itemDocID,
      'itemName':itemName,
      'itemTotal':itemTotal,
      'lastUpdated':lastUpdated,
      'purchasedByUID':purchasedByUID,
      'tripDocID':tripDocID,
      'users':users,
      'userSelectedList':userSelectedList
    };
  }
}
class CostObject {
  double amountOwe;
  Timestamp datePaid;
  String itemDocID;
  Timestamp lastUpdated;
  bool paid;
  String uid;
  String tripDocID;

  CostObject({
    this.amountOwe,
    this.datePaid,
    this.itemDocID,
    this.lastUpdated,
    this.paid,
    this.uid,
    this.tripDocID});


  CostObject.fromData(Map<String, dynamic> data):
        amountOwe = data['amountOwe'] ?? '',
        datePaid = data['datePaid'] ?? null,
        itemDocID = data['itemDocID'] ?? '',
        lastUpdated = data['lastUpdated'] ?? null,
        paid = data['paid'] ?? '',
        tripDocID = data['tripDocID'] ?? '',
        uid = data['uid'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'amountOwe': amountOwe,
      'datePaid': datePaid,
      'itemDocID': itemDocID,
      'lastUpdated':lastUpdated,
      'paid': paid,
      'tripDocID': tripDocID,
      'uid': uid,
    };
  }
}
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
  Widget SplitItemExist(BuildContext context, SplitObject splitObject, {Trip trip}){
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
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
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
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: ElevatedButton(
                          //     style: ButtonStyle(
                          //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          //           RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(20),
                          //           )
                          //       ),
                          //     ),
                          //     child: Text('Custom',style: Theme.of(context).textTheme.subtitle1,),
                          //     onPressed: (){
                          //       splitObject.dateCreated = Timestamp.now();
                          //       splitObject.lastUpdated = Timestamp.now();
                          //       DatabaseService().createSplitItem(splitObject);
                          //       navigationService.pop();
                          //       navigationService.navigateTo(CostPageRoute,);
                          //     },
                          //   ),
                          // ),
                      //   ],
                      // ),
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




class MembersLayout extends StatefulWidget{

  final Trip tripDetails;
  final String ownerID;

  MembersLayout({Key key, this.tripDetails, this.ownerID}) : super(key: key);

  @override
  _MembersLayoutState createState() => _MembersLayoutState();
}

class _MembersLayoutState extends State<MembersLayout> {

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


  Widget getMember(BuildContext context, Trip tripDetails){
    return Stack(
      children: [
        StreamBuilder(
          builder: (context, userData){
            if(userData.hasError){
              CloudFunction().logError('Error streaming user data for members layout: ${userData.error.toString()}');
            }
            if(userData.hasData){
              List<UserPublicProfile> crew = userData.data;
              return ListView.builder(
                itemCount: crew.length,
                itemBuilder: (context, index) {
                  UserPublicProfile member = crew[index];
                  return userCard(context, member, tripDetails);
                },
              );
            } else {
              return Loading();
            }
          },
          stream: DatabaseService().getcrewList(widget.tripDetails.accessUsers),),
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
            child: Container(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: _image.isNotEmpty ? Image.network(_image, height: 300,
                    width: 300,fit: BoxFit.fill,) : Image.asset(
                    profileImagePlaceholder,height: 300,
                    width: 300,fit: BoxFit.fill,),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget userCard(BuildContext context, UserPublicProfile member, Trip tripDetails){

    return Card(
      key: Key(member.uid),
      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
      child: Container(
        child: GestureDetector(
          onLongPress: (){
            setState(() {
              _showImage = true;
              _image = member.urlToImage;
            });
          },
          onLongPressEnd: (details) {
            setState(() {
              _showImage = false;
            });
          },
          onTap: (){
            navigationService.navigateTo(UserProfilePageRoute, arguments: member);
          },
          child: CheckboxListTile(
            value: !selectedList.value.contains(member.uid),
            onChanged: (bool value) {
              setState(() {
                if(value) {
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
                child: member.urlToImage.isNotEmpty ? Image.network(member.urlToImage,height: 75, width: 75,fit: BoxFit.fill,): null,
              ),
            ),
            title: Text("${member.displayName}",style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.start,),
            ),
          ),
        ),
    );
  }
}