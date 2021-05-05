// import 'package:draggable_scrollbar/draggable_scrollbar.dart';
// import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/search_bar/gf_search_bar.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/locator.dart';
import '../../../services/widgets/loading.dart';
import 'tc_user_card.dart';


class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();

}

class _UserListState extends State<UserList> {

  List<UserPublicProfile> allUsersList;
  final ScrollController controller = ScrollController();
  bool _isSearching = false;
  var userService = locator<UserService>();

  void pressedSearch(){
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = true;

    final usersList = Provider.of<List<UserPublicProfile>>(context);

    if (usersList != null) {
      allUsersList = usersList.where((user) => user.uid != userService.currentUserID).toList();
    }

    if(allUsersList != null) {
      setState(() {
       loading = false;
      });
    }
    
    Future<List<UserPublicProfile>> userSearchList (String name) async {
      String val = name.toLowerCase();
      var results = allUsersList.where((user) =>
      user.displayName.toLowerCase().contains(val)
          || user.firstName.toLowerCase().contains(val) ||
      user.lastName.toLowerCase().contains(val) || user.displayName.toLowerCase().contains(val)
      ).toList();
      return results;
    }

    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('TC Members',style: Theme.of(context).textTheme.headline3,),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.search),
          onPressed: (){
            pressedSearch();
          },)
        ],
      ),
      body: _isSearching ? GFSearchBar(
        // onSearch: userSearchList,
        // textStyle: Theme.of(context).textTheme.subtitle1,
        searchList: allUsersList,
        searchQueryBuilder: (query, list){
          return allUsersList.where((user) =>
          user.displayName.toLowerCase().contains(query.toLowerCase())
              || user.firstName.toLowerCase().contains(query.toLowerCase()) ||
              user.lastName.toLowerCase().contains(query.toLowerCase()) || user.displayName.toLowerCase().contains(query.toLowerCase())
          ).toList();
        },
        // placeHolder: ListView.builder(
        //     controller: controller,
        //     itemCount: allUsersList.length ?? 0,
        //     itemBuilder: (context, index){
        //       return TCUserCard(allUsers: allUsersList[index]);
        //     }),
        onItemSelected: (user){
          return TCUserCard(allUsers: user);
        },
      ): DraggableScrollbar.semicircle(
        controller: controller,
        child: ListView.builder(
            controller: controller,
            itemCount: allUsersList.length ?? 0,
            itemBuilder: (context, index){
              return TCUserCard(allUsers: allUsersList[index]);
            }),

      ),
    );


  }
}