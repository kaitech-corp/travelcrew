import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';

import 'lists/item_lists.dart';

class ListWidget extends StatefulWidget{

  final Trip tripDetails;

  const ListWidget({Key key, this.tripDetails}) : super(key: key);

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
        ],
      )
    ];
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {

        showBottomSheet(
          context: context,
          builder: (context) => DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: TabBar(
                labelStyle: Theme.of(context).textTheme.subtitle1,
                labelColor: Colors.black,
                tabs: <Widget>[
                  Tab(text: 'Bringing'),
                  Tab(text: 'Need',),
                ],
              ),
              body: Container(
                height: MediaQuery.of(context).size.height,
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
          ),
        );
      },
      child: Text('Add to List'),
    );
  }
}