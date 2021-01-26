import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/apis/api.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../../../services/widgets/loading.dart';


class BringingList extends StatefulWidget{

  final String documentID;
  BringingList({this.documentID});

  @override
  _BringingListState createState() => _BringingListState();
}

class _BringingListState extends State<BringingList> {
  List _selectedProducts = List();

  void _onSelectedProduct(bool selected, productName) {
    if (selected == true) {
      setState(() {
        _selectedProducts.add(productName);
        CloudFunction().addItemToBringingList(widget.documentID, productName);
        Scaffold
            .of(context)
            .showSnackBar(SnackBar(content: Text("Item added")));
      });
    } else {
      setState(() {
        _selectedProducts.remove(productName);
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
          textStyle: Theme.of(context).textTheme.subtitle2,
          cancellationWidget: const Text('Clear'),
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


  final String documentID;
  NeedList({this.documentID});



  @override
  _NeedListState createState() => _NeedListState();
}

class _NeedListState extends State<NeedList> {


  List _selectedProducts = List();

  void _onSelectedProduct(bool selected, productName) {
    if (selected == true) {
      setState(() {
        _selectedProducts.add(productName);
      });
    } else {
      setState(() {
        _selectedProducts.remove(productName);
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
            textStyle: Theme.of(context).textTheme.subtitle2,
            cancellationWidget:const Text('Clear'),
            placeHolder: NeedListToDisplay(documentID: widget.documentID,),
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
                        CloudFunction().addItemToNeedList(widget.documentID, product.query, currentUserProfile.displayName);
                        // DatabaseService().addItemToNeedList(
                        //     widget.documentID, product.query, widget.profileService.currentUserProfileDirect().displayName);
                        Scaffold
                            .of(context)
                            .showSnackBar(SnackBar(content: const Text("Item added")));
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
}

class NeedListToDisplay extends StatelessWidget{
  final documentID;

  const NeedListToDisplay({Key key, this.documentID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: MediaQuery.of(context).size.height * .4,
        child: needList(context),
      ),
    );
  }
    Widget needList(context){

    void _onSelectedItems(Need item) {
      CloudFunction().addItemToBringingList(documentID, item.item);
      CloudFunction().removeItemFromNeedList(documentID, item.documentID);
      Scaffold
          .of(context)
          .showSnackBar(SnackBar(
          content: const Text("Item added to Bringing list")));
    }
    return StreamBuilder(
      builder: (context, items) {
        if(items.hasError){
          CloudFunction().logError('Error streaming items in need list to display: ${items.error.toString()}');
        }
        if (items.hasData) {
          return ListView.builder(
            itemCount: items.data.length,
            itemBuilder: (context, index) {
              Need item = items.data[index];
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Align(alignment: Alignment.centerRight,child: const Icon(Icons.delete, color: Colors.white,)),
                ),
                key: Key(item.documentID),
                onDismissed: (direction) {
                  CloudFunction().removeItemFromNeedList(documentID, item.documentID);
                  // DatabaseService().removeItemFromNeedList(documentID, item.documentID);
                  Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: const Text("Item removed")));
                },
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.shopping_basket),),
                  title: Text(item.item.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
                  subtitle: Text(item.displayName,style: Theme.of(context).textTheme.subtitle2,),
                  trailing: const Icon(Icons.add),
                  onTap: (){
                      _onSelectedItems(item);
                  },
                ),
              );
            },
          );
        } else {
          return Loading();
        }
      },
      stream: DatabaseService().getNeedList(documentID),
    );
  }
}
class BringListToDisplay extends StatelessWidget{

  final String tripDocID;
  BringListToDisplay({this.tripDocID});

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
        if(items.hasError){
          CloudFunction().logError('Error streaming items in bringing list to display: ${items.error.toString()}');
        }
        if (items.hasData) {
          return ListView.builder(
            itemCount: items.data.length,
            itemBuilder: (context, index) {
              Bringing item = items.data[index];
              return ListTile(
                key: Key(item.documentID),
                onLongPress: (){
                  TravelCrewAlertDialogs().deleteBringinItemAlert(context, tripDocID, item.documentID);
                },
                leading: CircleAvatar(child: Icon(Icons.shopping_basket),),
                title: Text(item.item.toUpperCase(),style: Theme.of(context).textTheme.subtitle1,),
                subtitle: Text(item.displayName,style: Theme.of(context).textTheme.subtitle2,),
                trailing: IconButton(
                  icon: BadgeIcon(
                    icon: favorite(item),
                    badgeCount: item.voters?.length ?? 0,
                  ),
                  onPressed: (){
                    if (item.voters?.contains(currentUserProfile.uid) ?? false) {
                      CloudFunction().removeVoterFromBringingItem(tripDocID: tripDocID, documentID: item.documentID);
                    } else {
                      CloudFunction().addVoterToBringingItem(tripDocID: tripDocID, documentID: item.documentID);
                    }

                  },
                ),
              );
            },
          );
        } else {
          return Loading();
        }
      },
      stream: DatabaseService().getBringingList(tripDocID),
      // future: ,
    );
  }
  favorite(Bringing item){
    if (item.voters?.contains(currentUserProfile.uid) ?? false){
      return const Icon(Icons.favorite,color: Colors.red);
    } else {
      return const Icon(Icons.favorite_border,color: Colors.red);
    }
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Custom Item',
                      ),
                        validator: (value) {
                          // ignore: missing_return
                          if (value.isEmpty){
                            return 'Please enter an item first.';
                            // ignore: missing_return
                          }
                        },
                        onChanged: (val) =>
                        {
                          item = val,
                        }
                    ),
                      const Padding(padding: EdgeInsets.only(top: 20),),
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
                                .showSnackBar(SnackBar(content: const Text("Item added to Bringing list")));
                            } else{
                              CloudFunction().addItemToNeedList(widget.documentID, item, currentUserProfile.displayName);
                              Scaffold.of(context)
                                  .showSnackBar(SnackBar(content: const Text("Item added to Need list")));
                            }
                            form.reset();
                          }
                        },
                        child: const Text('Save'))
                    ],))),
        ],
      ),
    );
  }
}