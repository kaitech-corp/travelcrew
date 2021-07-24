import 'package:flutter/material.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'item_lists.dart';

class AddToListPage extends StatefulWidget{

  final Trip tripDetails;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PersistentBottomSheetController controller;

  AddToListPage({Key key, this.tripDetails, this.scaffoldKey,this.controller}) : super(key: key);

  @override
  _AddToListPageState createState() => _AddToListPageState();
}

class _AddToListPageState extends State<AddToListPage> {
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
}
