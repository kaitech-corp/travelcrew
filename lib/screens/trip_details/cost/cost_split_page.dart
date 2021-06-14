import 'package:flutter/material.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/cost/split_package.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';

class CostPage extends StatefulWidget{

  final Trip tripDetails;
  CostPage({this.tripDetails});

  @override
  _CostPageState createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {

  List<ExpansionItem> expansionItems = List<ExpansionItem>.generate(10, (int index)=> ExpansionItem(isExpanded: false,));

  
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Split',style: Theme.of(context).textTheme.headline3,),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Container(
            // height: SizeConfig.screenHeight,
            // width: SizeConfig.screenWidth,
            child: StreamBuilder(
              builder: (context, streamData){
                if(streamData.hasData){
                  List<SplitObject> items = streamData.data;
                  for (var i = 0; i < items.length; i++){
                    try {
                      expansionItems[i].item =items[i];
                      expansionItems[i].headerValue =items[i].itemName;
                    } catch (e) {
                      if(e.toString().contains('RangeError')) {
                        expansionItems.add(ExpansionItem(
                            item: items[i], headerValue: items[i].itemName));
                      }
                    }
                  }
                  expansionItems = expansionItems.getRange(0, items.length).toList();

                  return _buildListPanel(expansionItems);
                } else if(streamData.hasData && streamData.connectionState == ConnectionState.done){
                  return ListTile(
                    title: const Text('No items have been split.'),
                  );
                } else {
                  return Loading();
                }
              },
              stream: DatabaseService(tripDocID: widget.tripDetails?.documentId).splitItemData,
            ),
          ),
        ),
      )
    );
  }

  Widget _buildListPanel(List<ExpansionItem> expansionItems){

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded){
        setState(() {
          expansionItems[index].isExpanded = !isExpanded;
        });
      },
      children: expansionItems.map<ExpansionPanel>((ExpansionItem item){
        return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onLongPress: (){
                  if (userService.currentUserID == item.item.purchasedByUID) {
                    SplitPackage().editSplitDialog(context, item.item);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.item.itemName, style: Theme
                          .of(context)
                          .textTheme
                          .headline1,),
                      Text('Total: \$${item.item.itemTotal.toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cantata One',color: Colors.green)),
                      Text('Remaining: \$${item.item?.amountRemaining.toStringAsFixed(2) ?? item.item.itemTotal.toStringAsFixed(2)}  (${item.item.userSelectedList.length}pp)',style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cantata One',color: Colors.red)),
                      // Text('Description: ${item.itemType}',style: Theme.of(context).textTheme.subtitle2),
                      FutureBuilder(
                        builder: (context, snapshot){
                          if(snapshot.hasData){
                            UserPublicProfile user = snapshot.data;
                            return Text('Purchased by: ${user.displayName}',style: Theme.of(context).textTheme.subtitle2);
                          } else {
                            return Container();
                          }
                        },
                        future: DatabaseService().getUserProfile(item.item.purchasedByUID),
                      ),
                      Text('Last Updated: ${TCFunctions().formatTimestamp(item.item.lastUpdated,wTime: true)}',style: Theme.of(context).textTheme.headline6),
                    ],
                  ),
              ),
            );
            },
            body: costDetailsStream(item.item, item.item.purchasedByUID),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  Widget costDetailsStream(SplitObject splitObject, String purchasedByUID) {
    return SingleChildScrollView(
      child: Container(
        height: SizeConfig.screenHeight*.4,
        width: SizeConfig.screenWidth,
        child: StreamBuilder2(
          streams: Tuple2(DatabaseService(itemDocID: splitObject.itemDocID,tripDocID: splitObject.tripDocID).costDataList,DatabaseService().getcrewList(widget.tripDetails.accessUsers),),
          builder: (context, snapshots){
            if(snapshots.item1.hasData && snapshots.item2.hasData){
              List<CostObject> userCostData = snapshots.item1.data;
              List<String> uidList = [];
              userCostData.forEach((element) {
                if (!uidList.contains(element.uid)) {
                  uidList.add(element.uid);
                }
              });

              var amountRemaining = SplitPackage().sumRemainingBalance(userCostData);
              ///Update remaining balance by checking if each outstanding balance adds up correctly
              if(amountRemaining != splitObject.amountRemaining){
                DatabaseService().updateRemainingBalance(splitObject,amountRemaining, uidList);
              }
              List<UserPublicProfile> userPublicData = snapshots.item2.data;
                return ListView.builder(
                  itemCount: userCostData.length,
                    itemBuilder: (context, index){
                    CostObject costObject = userCostData[index];
                    UserPublicProfile userPublicProfile = userPublicData.firstWhere((element) => element.uid == costObject.uid);
                    UserPublicProfile purchasedByUser = userPublicData.firstWhere((element) => element.uid == purchasedByUID);
                    if(userPublicProfile.uid != purchasedByUID) {
                      return InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                            ),
                            builder: (context) => UserSplitCostDetailsBottomSheet(user: userPublicProfile, costObject: costObject,purchasedByUser: purchasedByUser,splitObject: splitObject,),
                          );
                        },
                        child: Container(
                          height: SizeConfig.screenHeight * .1,
                          width: SizeConfig.screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey[100],
                              )
                            )
                          ),
                          padding: EdgeInsets.all(4),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: userPublicProfile.urlToImage.isNotEmpty ?
                              Image.network(userPublicProfile.urlToImage,height: 50, width: 50,fit: BoxFit.fill,):
                              Image.asset(profileImagePlaceholder,height: 50,width: 50,fit: BoxFit.fill,),
                            ),
                            title: Text('${userPublicProfile.displayName}',
                              style: Theme.of(context).textTheme.subtitle1),
                            subtitle: (costObject.paid == false) ?
                            Text('Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cantata One',color: Colors.red)) :
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Paid',style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cantata One',color: Colors.green)),
                                Text(TCFunctions().formatTimestamp(costObject.datePaid,wTime: true),style: Theme.of(context).textTheme.headline6),
                              ],
                            ),
                            trailing: (splitObject.purchasedByUID == userService.currentUserID || costObject.uid == userService.currentUserID && costObject.paid == false) ?
                            ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      )
                                  )),
                              child: Text('Paid'),
                              onPressed: (){
                                DatabaseService().markAsPaid(costObject,splitObject);
                              },
                            ) : null,
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  });
              } else {
                return const Text('Empty');
              }
            },

            ),
      ),
    );
  }
}

class UserSplitCostDetailsBottomSheet extends StatelessWidget {
  const UserSplitCostDetailsBottomSheet({
    Key key,
    @required this.user,
    @required this.costObject,
    this.splitObject,
    this.purchasedByUser,
  }) : super(key: key);

  final UserPublicProfile user;
  final CostObject costObject;
  final SplitObject splitObject;
  final UserPublicProfile purchasedByUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: (ThemeProvider.themeOf(context).id == 'light_theme') ?
      BoxDecoration(
        // borderRadius: BorderRadius.circular(30),
        // borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Colors.blue.shade50,
              Colors.lightBlueAccent.shade200
            ]
        ),
      ): BoxDecoration(
        // borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade700,
              Color(0xAA2D3D49)
            ]
        ),
      ),
      padding: const EdgeInsets.all(10),
      height: SizeConfig.screenHeight*.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: SizeConfig.screenWidth/6,
            backgroundImage: user.urlToImage.isNotEmpty ? NetworkImage(user.urlToImage,) : AssetImage(profileImagePlaceholder),
          ),
          Text(user.displayName,style: Theme.of(context).textTheme.headline1),
          Container(height: 10,),
          Text('Payment details for:',style: Theme.of(context).textTheme.headline2, textAlign: TextAlign.center,),
          Text('"${splitObject.itemName}"',style: Theme.of(context).textTheme.headline2, textAlign: TextAlign.center,maxLines: 5,),
          ListTile(
            title: (costObject.paid == false) ?
            Text('Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',style: Theme.of(context).textTheme.subtitle1) :
            Text('Paid',style: Theme.of(context).textTheme.subtitle1),
            subtitle: (userService.currentUserID == purchasedByUser.uid) ?
            Text('Paid to: You',style: Theme.of(context).textTheme.subtitle2) :
            Text('Paid to: ${purchasedByUser.displayName}',style: Theme.of(context).textTheme.subtitle2),
            trailing: (user.uid == userService.currentUserID || userService.currentUserID == purchasedByUser.uid) ?
            PaymentDetailsMenuButton(costObject: costObject,splitObject: splitObject,) : null,
          ),
          (user.uid == userService.currentUserID || userService.currentUserID == purchasedByUser.uid) ? ElevatedButton(
              onPressed: (){
                DatabaseService().markAsPaid(costObject,splitObject);
              },
              child: const Text('Paid'),
          ) : Container(),
        ],
      ),
    );
  }
}

class PaymentDetailsMenuButton extends StatelessWidget {
  const PaymentDetailsMenuButton({
    Key key,
    @required this.costObject,
    this.splitObject,

  }) : super(key: key);

  final CostObject costObject;
  final SplitObject splitObject;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        icon: IconThemeWidget(icon: Icons.edit,),
        onSelected: (value) {
          switch (value) {
            case "Edit":
              {

              }
              break;
            case "Delete":
              {
                DatabaseService().deleteCostObject(costObject, splitObject);
                navigationService.pop();
              }
              break;
            default:
              {

              }
              break;
          }
        },
        padding: EdgeInsets.zero,
        itemBuilder: (context) =>
        [
          // const PopupMenuItem(
          //   value: 'Edit',
          //   child: ListTile(
          //     leading: IconThemeWidget(icon: Icons.edit),
          //     title: const Text('Edit'),
          //   ),
          // ),
          const PopupMenuItem(
            value: 'Delete',
            child: ListTile(
              leading: IconThemeWidget(icon: Icons.delete),
              title: const Text('Remove'),
            ),
          ),
        ],
      );
  }
}