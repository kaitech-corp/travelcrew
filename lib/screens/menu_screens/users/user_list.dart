import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import '../../../loading.dart';
import 'users_text_section.dart';


class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();

}

class _UserListState extends State<UserList> {

  final ScrollController controller = ScrollController();
  bool _isSearching = false;

  void pressedSearch(){
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = true;
    final allUsersList = Provider.of<List<UserProfile>>(context);

    if(allUsersList != null) {
      setState(() {
       loading = false;
      });
    }
    
    Future<List<UserProfile>> userSearchList (String name) async {
      String val = name.toLowerCase();
      var results = allUsersList.where((user) =>
      user.displayName.toLowerCase().contains(val)
          || user.firstName.toLowerCase().contains(val) ||
      user.lastName.toLowerCase().contains(val)
      ).toList();
      return results;
    }

    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search),
          onPressed: (){
            pressedSearch();
          },)
        ],
      ),
      body: _isSearching ? SearchBar(
        onSearch: userSearchList,
        placeHolder: DraggableScrollbar.semicircle(
          controller: controller,
          child: ListView.builder(
              controller: controller,
              itemCount: allUsersList.length ?? 0,
              itemBuilder: (context, index){
                return UsersTextSection(allUsers: allUsersList[index]);
              }),
        ),
        onItemFound: (UserProfile user, int index){
          return UsersTextSection(allUsers: user);
        },
      ): DraggableScrollbar.semicircle(
        controller: controller,
        child: ListView.builder(
            controller: controller,
            itemCount: allUsersList.length ?? 0,
            itemBuilder: (context, index){
              return UsersTextSection(allUsers: allUsersList[index]);
            }),

      ),
    );


  }
}