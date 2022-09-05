import 'package:flutter/material.dart';

import '../../../../models/trip_model.dart';
import '../../basket_list/controller/basket_controller.dart';
import 'item_lists.dart';

/// Add to list page
class AddToListPage extends StatefulWidget{

  const AddToListPage({Key? key, required this.trip, this.scaffoldKey, required this.controller}) : super(key: key);

  final Trip trip;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BasketController controller;

  @override
  _AddToListPageState createState() => _AddToListPageState();
}

class _AddToListPageState extends State<AddToListPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      TabBarView(
        children: [
          BringingList(documentID: widget.trip.documentId,controller: widget.controller,),
          CustomList(documentID: widget.trip.documentId,)
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
                  tabs: const <Widget>[
                    Tab(text: 'Bringing'),
                    // const Tab(text: 'Need',),
                    Tab(text: 'Custom',)
                  ],
                ),
                body: widgetOptions.elementAt(_selectedIndex),
              ),
            );
  }
}
