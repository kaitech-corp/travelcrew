import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'lists/item_lists.dart';

class ListWidget extends StatefulWidget{

  final Trip tripDetails;
  final GlobalKey<ScaffoldState> scaffoldKey;
  PersistentBottomSheetController controller;

  ListWidget({Key key, this.tripDetails, this.scaffoldKey,this.controller}) : super(key: key);

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
//    print(members);
    final List<Widget> _widgetOptions = <Widget>[
      TabBarView(
        children: [
          BringingList(documentID: widget.tripDetails.documentId,),
          NeedList(documentID: widget.tripDetails.documentId,),
          CustomList(documentID: widget.tripDetails.documentId,)
        ],
      )
    ];
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }
    return ElevatedButton(
      onPressed: () {
        widget.controller = widget.scaffoldKey.currentState.showBottomSheet(
          (BuildContext context) {
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: TabBar(
                  labelStyle: Theme
                      .of(context)
                      .textTheme
                      .subtitle1,
                  tabs: <Widget>[
                    const Tab(text: 'Bringing'),
                    const Tab(text: 'Need',),
                    const Tab(text: 'Custom',)
                  ],
                ),
                body: Container(
                  padding: const EdgeInsets.all(10),
                  height: SizeConfig.screenHeight,
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ),
            );
          }
        );
      },
      child: const Text('Add to List'),
    );
  }
}

class SplitButton extends StatelessWidget {

  final Trip tripDetails;

  const SplitButton({
    Key key, this.tripDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        navigationService.navigateTo(CostPageRoute, arguments: tripDetails);
      },
      child: const Text('Split'),
    );
  }
}