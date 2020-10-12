import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/api.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../../../loading.dart';


class BringingList extends StatefulWidget{

  var userService = locator<UserService>();

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
        CloudFunction().addItemToBringingList(widget.documentID, product_name);
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text("Item added")));
      });
    } else {
      setState(() {
        _selectedProducts.remove(product_name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Container(
        // constraints: BoxConstraints.expand(),
        height: MediaQuery.of(context).size.height,
        child: SearchBar(
          cancellationWidget: Text('Clear'),
            placeHolder: Text('  i.e. Cups, Doritos, Flashlight',style: Theme.of(context).textTheme.subtitle2,),
            onSearch: WalmartProductSearch().getProducts,
            onItemFound: (WalmartProducts product, int index) {
              return CheckboxListTile(
                title: Text(product.query),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _selectedProducts.contains(product.query),
                onChanged: (bool selected){
                  setState(() {
                    _onSelectedProduct(selected, product.query);
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

  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

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

    return SingleChildScrollView(
      child: Container(
        // constraints: BoxConstraints.expand(),
        height: MediaQuery.of(context).size.height,
        child:  SearchBar(
            cancellationWidget: Text('Clear'),
            placeHolder: needList(),
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
                        CloudFunction().addItemToNeedList(widget.documentID, product.query, widget.currentUserProfile.displayName);
                        // DatabaseService().addItemToNeedList(
                        //     widget.documentID, product.query, widget.profileService.currentUserProfileDirect().displayName);
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

  Widget needList() {

    void _onSelectedItems(Need item) {
          CloudFunction().addItemToBringingList(widget.documentID, item.item);
          CloudFunction().removeItemFromNeedList(widget.documentID, item.documentID);
          Scaffold
              .of(context)
              .showSnackBar(SnackBar(
                content: Text("Item added to Bringing list")));
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
                key: Key(item.documentID),
                onDismissed: (direction) {
                  CloudFunction().removeItemFromNeedList(widget.documentID, item.documentID);
                  // DatabaseService().removeItemFromNeedList(widget.documentID, item.documentID);
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("Item removed")));
                },
                child: ListTile(
                  title: Text(item.item.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
                  subtitle: Text(item.displayName,style: Theme.of(context).textTheme.subtitle2,),
                  trailing: Icon(Icons.add),
                  onTap: (){
                      setState(() {
                        _onSelectedItems(item);
                      });
                  },
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
                key: Key(item.documentID),
                onDismissed: (direction) {
                  CloudFunction().removeItemFromBringingList(documentID, item.documentID);
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("Item removed")));
                },
                child:
                  // Widget to display the list of project
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.shopping_basket),),
                    title: Text(item.item.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
                    subtitle: Text(item.displayName,style: Theme.of(context).textTheme.subtitle2,),
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

class CustomList extends StatefulWidget{

  final String documentID;

  CustomList({Key key, this.documentID}) : super(key: key);

  @override
  _CustomListState createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  final _formKey = GlobalKey<FormState>();

  String item;

  String option = 'Bringing';

  List optionList = ['Bringing', 'Need'];

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 5),),
          Builder(
              builder: (context) => Form(
                  key: _formKey,
                  child: Column(
                    children: [
                    TextFormField(
                      enableInteractiveSelection: true,
                      maxLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Custom Item',
                      ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter an item first.';
                            // ignore: missing_return
                          }
                        },
                        onChanged: (val) =>
                        {
                          item = val,
                        }
                    ),
                      Padding(padding: EdgeInsets.only(top: 20),),
                      Container(
                        height: SizeConfig.screenHeight*.15,
                        child: ListView.builder(
                            itemCount: optionList.length,
                            itemBuilder: (context, index) {
                              return RadioListTile(
                                  title: Text(optionList[index]),
                                  value: optionList[index],
                                  groupValue: option,
                                  onChanged: (value) {
                                    setState(() {
                                      option = value;
                                    });
                                  }
                              );
                            }
                        ),
                      ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          final form = _formKey.currentState;
                          if (form.validate()) {
                            if(option == 'Bringing'){
                              CloudFunction().addItemToBringingList(widget.documentID, item);
                            Scaffold.of(context)
                                .showSnackBar(SnackBar(content: Text("Item added to Bringing list")));
                            } else{
                              CloudFunction().addItemToNeedList(widget.documentID, item, currentUserProfile.displayName);
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(content: Text("Item added to Need list")));
                            }
                            form.reset();
                          }
                        },
                        child: Text('Save'))
                    ],))),
        ],
      ),
    );
  }
}