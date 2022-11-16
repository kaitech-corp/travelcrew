import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';
import '../../../../services/apis/api.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../../../../services/widgets/badge_icon.dart';
import '../../../../services/widgets/basket_icon.dart';
import '../../../../services/widgets/favorite_widget.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../../alerts/alert_dialogs.dart';
import '../../../authenticate/profile_stream.dart';
import '../../basket_list/controller/basket_controller.dart';

/// Bringing List
class BringingList extends StatefulWidget {
  const BringingList(
      {Key? key, required this.documentID, required this.controller})
      : super(key: key);
  final String documentID;
  final BasketController controller;

  @override
  State<BringingList> createState() => _BringingListState();
}

class _BringingListState extends State<BringingList> {
  final List<String> _selectedProducts = <String>[];

  void _onSelectedProduct(bool selected, WalmartProducts product) {
    if (selected == true) {
      setState(() {
        _selectedProducts.add(product.query!);
        CloudFunction().addItemToBringingList(
            widget.documentID, product.query, product.type);
        widget.controller.addWalmartProductsToCart(product);
      });
    } else {
      setState(() {
        _selectedProducts.remove(product.query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.blue.shade100,
        child: SearchBar(
            textStyle: Theme.of(context).textTheme.subtitle2!,
            cancellationWidget: const Text('Clear'),
            placeHolder: Text(
              '  i.e. Cups, Doritos, Flashlight',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            onSearch: WalmartProductSearch().getProducts,
            crossAxisCount: 2,
            onItemFound: (WalmartProducts product, int index) {
              // return
              return CheckboxListTile(
                title: Text(product.query!),
                // subtitle: Text(product.department[0]['name'] ?? 'Unknown'),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _selectedProducts.contains(product.query),
                onChanged: (bool? selected) {
                  setState(() {
                    _onSelectedProduct(selected!, product);
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

class NeedList extends StatefulWidget {
  const NeedList({Key? key, required this.documentID}) : super(key: key);
  final String documentID;

  @override
  State<NeedList> createState() => _NeedListState();
}

class _NeedListState extends State<NeedList> {
  final List<String> _selectedProducts = <String>[];

  void _onSelectedProduct(bool selected, String productName) {
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

  static const int historyLength = 5;
  late bool selected;
  String query = 'chips';
  List<String> filteredSearchHistory = <String>[];
  final List<String> _searchHistory = <String>[];
  List<WalmartProducts> queryResults = <WalmartProducts>[];
  late TextEditingController controller;

  List<String> filterSearchTerms({
    String? filter,
  }) {
    if (filter?.isNotEmpty ?? false) {
      return _searchHistory.reversed
          .where((String term) => term.startsWith(filter!))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }

    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }

    filteredSearchHistory = filterSearchTerms();
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((String t) => t == term);
    filteredSearchHistory = filterSearchTerms();
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  void searchForQuery([String? item]) {
    if (query.length > 2) {
      setState(() async {
        queryResults = await WalmartProductSearch().getProducts(query);
      });
    } else if (item != null) {
      setState(() async {
        queryResults = await WalmartProductSearch().getProducts(item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    filteredSearchHistory = filterSearchTerms();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SearchBar(
            textStyle: Theme.of(context).textTheme.subtitle2!,
            cancellationWidget: const Text('Clear'),
            placeHolder: NeedListToDisplay(
              documentID: widget.documentID,
            ),
            onSearch: WalmartProductSearch().getProducts,
            onItemFound: (WalmartProducts product, int index) {
              return CheckboxListTile(
                title: Text(product.query ?? ''),
                controlAffinity: ListTileControlAffinity.trailing,
                value: _selectedProducts.contains(product.query),
                onChanged: (bool? selected) {
                  setState(() {
                    _onSelectedProduct(selected!, product.query!);
                    if (selected == true) {
                      try {
                        CloudFunction().addItemToNeedList(widget.documentID,
                            product.query!, currentUserProfile.displayName, '');
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item added')));
                      } catch (e) {
                        // TODO(Randy): log error.
                      }
                    } else {
                      // TODO(Randy): change to delete.
                      _onSelectedProduct(selected, product.query!);
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

  Widget productTile(WalmartProducts product) {
    return CheckboxListTile(
      title: Text(product.query!),
      controlAffinity: ListTileControlAffinity.trailing,
      value: _selectedProducts.contains(product.query),
      onChanged: (bool? selected) {
        setState(() {
          _onSelectedProduct(selected!, product.query!);
          if (selected == true) {
            try {
              CloudFunction().addItemToNeedList(widget.documentID,
                  product.query!, currentUserProfile.displayName, '');
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Item added')));
            } catch (e) {
              CloudFunction()
                  .logError('Error adding item to Need List: ${e.toString()}');
            }
          } else {
            // TODO(Randy): change to delete
            _onSelectedProduct(selected, product.query!);
          }
        });
      },
      activeColor: Colors.green,
      checkColor: Colors.blueGrey,
    );
  }
}

class NeedListToDisplay extends StatelessWidget {
  const NeedListToDisplay({Key? key, required this.documentID})
      : super(key: key);
  final String documentID;

  @override
  Widget build(BuildContext context) {
    void _onSelectedItems(Need item) {
      CloudFunction().addItemToBringingList(documentID, item.item, item.type);
      CloudFunction().removeItemFromNeedList(documentID, item.documentID!);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added to Bringing list')));
    }

    return StreamBuilder<List<Need>>(
      builder: (BuildContext context, AsyncSnapshot<List<Need>> items) {
        if (items.hasError) {
          CloudFunction().logError('Error streaming items in need '
              'list to display: ${items.error.toString()}');
        }
        if (items.hasData) {
          final List<Need> needList = items.data!;
          return ListView.builder(
            itemCount: needList.length,
            itemBuilder: (BuildContext context, int index) {
              final Need item = needList[index];
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      )),
                ),
                key: Key(item.documentID!),
                onDismissed: (DismissDirection direction) {
                  CloudFunction()
                      .removeItemFromNeedList(documentID, item.documentID!);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item removed')));
                },
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.shopping_basket),
                  ),
                  title: Text(
                    item.item!.toUpperCase(),
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  subtitle: Text(
                    'Suggested by: ${item.displayName}',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    _onSelectedItems(item);
                  },
                ),
              );
            },
          );
        } else {
          return const Loading();
        }
      },
      stream: DatabaseService().getNeedList(documentID),
    );
  }
}

class BringListToDisplay extends StatelessWidget {
  const BringListToDisplay({Key? key, required this.tripDocID})
      : super(key: key);
  final String tripDocID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Bringing>>(
      stream: DatabaseService().getBringingList(tripDocID),
      builder: (BuildContext context, AsyncSnapshot<List<Bringing>> items) {
        if (items.hasError) {
          CloudFunction().logError('Error streaming items in bringing '
              'list to display: ${items.error.toString()}');
        }
        if (items.hasData) {
          final List<Bringing> bringingList = items.data!;
          return ListView.builder(
            itemCount: bringingList.length,
            itemBuilder: (BuildContext context, int index) {
              final Bringing item = bringingList[index];
              return ListTile(
                key: Key(item.documentID!),
                onLongPress: () {
                  TravelCrewAlertDialogs().deleteBringingItemAlert(
                      context, tripDocID, item.documentID!);
                },
                leading: basketIcon(item.type),
                title: Text(
                  item.item!.toUpperCase(),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: Text(
                  item.displayName!,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                trailing: IconButton(
                  icon: BadgeIcon(
                    icon: FavoriteWidget(
                      uid: userService.currentUserID,
                      voters: item.voters ?? <String>[],
                    ),
                    badgeCount: item.voters?.length ?? 0,
                  ),
                  onPressed: () {
                    if (item.voters?.contains(userService.currentUserID) ??
                        false) {
                      CloudFunction().removeVoterFromBringingItem(
                          tripDocID: tripDocID, documentID: item.documentID!);
                    } else {
                      CloudFunction().addVoterToBringingItem(
                          tripDocID: tripDocID, documentID: item.documentID!);
                    }
                  },
                ),
              );
            },
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}

class CustomList extends StatefulWidget {
  const CustomList({Key? key, required this.documentID}) : super(key: key);
  final String documentID;

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController(text: '');
  String option = 'Bringing';
  List<String> optionList = <String>['Bringing'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 5),
          ),
          Builder(
              builder: (BuildContext context) => Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: controller,
                        enableInteractiveSelection: true,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Custom Item',
                        ),
                        validator: (String? value) {
                          // ignore: missing_return
                          if (value?.isEmpty ?? false) {
                            return 'Please enter an item first.';
                            // ignore: missing_return
                          }
                          return null;
                        },
                        // onChanged: (val) => {
                        //       item = val,
                        //     }
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      SizedBox(
                        height: SizeConfig.screenHeight * .15,
                        child: ListView.builder(
                            itemCount: optionList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return RadioListTile<String>(
                                  title: Text(optionList[index]),
                                  value: optionList[index],
                                  groupValue: option,
                                  onChanged: (String? value) {
                                    setState(() {
                                      option = value!;
                                    });
                                  });
                            }),
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            final FormState form = _formKey.currentState!;
                            form.save();
                            if (form.validate()) {
                              CloudFunction().addItemToBringingList(
                                  widget.documentID, controller.text, '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Item added to Bringing list')));
                              form.reset();
                            }
                          },
                          child: const Text('Save'))
                    ],
                  ))),
        ],
      ),
    );
  }
}
