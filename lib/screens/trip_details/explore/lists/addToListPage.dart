import 'package:flutter/material.dart';
import '../../../../models/trip_model.dart';
import '../../basket_list/controller/basket_controller.dart';

import 'item_lists.dart';

class AddToListPage extends StatefulWidget{

  final Trip tripDetails;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BasketController controller;

  AddToListPage({Key key, this.tripDetails, this.scaffoldKey,this.controller}) : super(key: key);

  @override
  _AddToListPageState createState() => _AddToListPageState();
}

class _AddToListPageState extends State<AddToListPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      TabBarView(
        children: [
          BringingList(documentID: widget.tripDetails.documentId,controller: widget.controller,),
          // NeedList(documentID: widget.tripDetails.documentId,),
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
              length: 2,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.blue.shade100,
                appBar: TabBar(
                  labelStyle: Theme
                      .of(context)
                      .textTheme
                      .subtitle1,
                  tabs: <Widget>[
                    const Tab(text: 'Bringing'),
                    // const Tab(text: 'Need',),
                    const Tab(text: 'Custom',)
                  ],
                ),
                body: _widgetOptions.elementAt(_selectedIndex),
              ),
            );
  }
}
