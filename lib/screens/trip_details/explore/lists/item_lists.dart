import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/api.dart';
import 'package:travelcrew/services/database.dart';
import '../../../loading.dart';


class BringingList extends StatefulWidget{

  final String documentID;
  BringingList({this.documentID});

  @override
  _BringingListState createState() => _BringingListState();
}

class _BringingListState extends State<BringingList> {
  List _selectedProducts = List();

  void _onSelectedProduct(bool selected, product_name) {
    if (selected == true) {
      setState(() {
        _selectedProducts.add(product_name);
      });
    } else {
      setState(() {
        _selectedProducts.remove(product_name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    return SingleChildScrollView(
      child: Container(
        // constraints: BoxConstraints.expand(),
        height: MediaQuery.of(context).size.height,
        child: SearchBar(
          cancellationWidget: Text('Clear'),
            placeHolder: Text('  i.e. Cups, Doritos, Dos Equis'),
            onSearch: WalmartProductSearch().getProducts,
            onItemFound: (WalmartProducts product, int index) {
              return CheckboxListTile(
                title: Text(product.query),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _selectedProducts.contains(product.query),
                onChanged: (bool selected){
                  setState(() {
                    _onSelectedProduct(selected, product.query);
                    try {
                      DatabaseService().addItemToBringingList(
                          widget.documentID, product.query, user.displayName);
                      Scaffold
                          .of(context)
                          .showSnackBar(SnackBar(content: Text("Item added")));
                    }catch(e){
                      print(e.toString());
                    }
                  });
                },
                activeColor: Colors.green,
                checkColor: Colors.blueGrey,
              );
            }),
      ),
    );
  }

}

class NeedList extends StatefulWidget{

  String documentID;
  NeedList({this.documentID});

  @override
  _NeedListState createState() => _NeedListState();
}

class _NeedListState extends State<NeedList> {

  List _selectedProducts = List();

  void _onSelectedProduct(bool selected, product_name) {
    if (selected == true) {
      setState(() {
        _selectedProducts.add(product_name);
      });
    } else {
      setState(() {
        _selectedProducts.remove(product_name);
      });
    }
  }

  bool selected;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);
    return SingleChildScrollView(
      child: Container(
        // constraints: BoxConstraints.expand(),
        height: MediaQuery.of(context).size.height,
        child:  SearchBar(
            cancellationWidget: Text('Clear'),
            placeHolder: needList(user.displayName),
            onSearch: WalmartProductSearch().getProducts,
            onItemFound: (WalmartProducts product, int index) {
              return CheckboxListTile(
                title: Text(product.query),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _selectedProducts.contains(product.query),
                onChanged: (bool selected){
                  setState(() {
                    _onSelectedProduct(selected, product.query);
                    if(selected ==true) {
                      try {
                        // print(widget.documentID);
                        DatabaseService().addItemToNeedList(
                            widget.documentID, product.query, user.displayName);
                        Scaffold
                            .of(context)
                            .showSnackBar(SnackBar(
                            content: Text("Item added")));
                      } catch (e) {
                        print(e.toString());
                      }
                    } else{
                        // TODO: change to delete 
                        _onSelectedProduct(selected, product.query);
                    }
                  });
                },
                activeColor: Colors.green,
                checkColor: Colors.blueGrey,
              );
            }),
      ),
    );
  }

  Widget needList(String displayName) {
    List _selectedItems = List();

    void _onSelectedItems(bool selected, Need item) {
      if (selected == true) {
        setState(() {
          _selectedItems.add(item.item);
        });
        try {
          DatabaseService().addItemToBringingList(
              widget.documentID, item.item, displayName);
          DatabaseService().removeItemFromNeedList(
              widget.documentID, item.documentID);
          Scaffold
              .of(context)
              .showSnackBar(SnackBar(
              content: Text("Item added to Bringing list")));
        } catch(e){
          print('Error in lists: ${e.toString()}');
        }
      } else {
        setState(() {
          _selectedItems.remove(item.item);
        });
      }
    }
    return StreamBuilder(
      builder: (context, items) {
        if (items.hasData) {
          return ListView.builder(
            itemCount: items.data.length,
            itemBuilder: (context, index) {
              Need item = items.data[index];
              return Dismissible(
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.delete, color: Colors.white,),
                      Icon(Icons.delete, color: Colors.white,)
                    ],
                  ),
                ),
                key: Key(item.item),
                onDismissed: (direction) {

                  DatabaseService().removeItemFromNeedList(widget.documentID, item.documentID);
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("Item removed")));
                },
                child: CheckboxListTile(
                  title: Text(item.item.toUpperCase()),
                  subtitle: Text(item.displayName),
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: _selectedItems.contains(item.item),
                  onChanged: (bool value){
                   setState(() {
                     _onSelectedItems(value, item);
                   });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.blueGrey,
                ),
              );
            },
          );
        } else {
          return Loading();
        }
      },
      stream: DatabaseService().getNeedList(widget.documentID),
    );
  }
}

class BringListToDisplay extends StatelessWidget{

  final String documentID;
  BringListToDisplay({this.documentID});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: MediaQuery.of(context).size.height * .4,
        child: bringList(),
      ),
    );
  }

  Widget bringList() {
    return StreamBuilder(
      builder: (context, items) {
        if (items.hasData) {
          return ListView.builder(
            itemCount: items.data.length,
            itemBuilder: (context, index) {
              Bringing item = items.data[index];
              return Dismissible(
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(Icons.delete, color: Colors.white,),
                      Icon(Icons.delete, color: Colors.white,)
                  ],
                ),
                ),
                key: Key(item.item),
                onDismissed: (direction) {
                  DatabaseService().removeItemFromBringingList(documentID, item.documentID);
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("Item removed")));
                },
                child:
                  // Widget to display the list of project
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.shopping_basket),),
                    title: Text(item.item.toUpperCase()),
                    subtitle: Text(item.displayName),
                  ),
              );
            },
          );
        } else {
          return Loading();
        }
      },
      stream: DatabaseService().getBringingList(documentID),
      // future: ,
    );
  }


}