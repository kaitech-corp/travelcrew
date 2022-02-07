import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/custom_objects.dart';
import '../../../../repositories_v2/all_users_repository.dart';
import '../../../../services/widgets/appbar_gradient.dart';
import '../../../../services/widgets/loading.dart';
import 'tc_user_card.dart';



class AllUserPage extends StatefulWidget {
  @override
  _AllUserPageState createState() => _AllUserPageState();

}

class _AllUserPageState extends State<AllUserPage> {

  GenericBloc<UserPublicProfile,AllUserRepository> bloc;

  final ScrollController controller = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<UserPublicProfile, AllUserRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
  }

  void pressedSearch(){
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {

    List<UserPublicProfile> allUsersSearchList;

    Future<List<UserPublicProfile>> userSearchList (String name) async {
      String val = name.toLowerCase();

      var results = allUsersSearchList.where((user) =>
      user.displayName.toLowerCase().contains(val)
          || user.firstName.toLowerCase().contains(val) ||
          user.lastName.toLowerCase().contains(val) || user.displayName.toLowerCase().contains(val)
      ).toList();
      return results;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('TC Members',style: Theme.of(context).textTheme.headline5,),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.search),
            onPressed: (){
              pressedSearch();
            },)
        ],
        flexibleSpace: AppBarGradient(),
      ),
      body: BlocBuilder<GenericBloc<UserPublicProfile, AllUserRepository>, GenericState>(
        // bloc: blocCurrent,
          builder: (context, state){
            if(state is LoadingState){
              return Loading();
            } else if (state is HasDataState<UserPublicProfile>){
              List<UserPublicProfile> allUsersList = state.data;
                allUsersSearchList = allUsersList;
              return _isSearching ? SearchBar(
                onSearch: userSearchList,
                textStyle: Theme.of(context).textTheme.subtitle1,
                placeHolder: DraggableScrollbar.semicircle(
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: allUsersList.length ?? 0,
                      itemBuilder: (context, index){
                        return TCUserCard(allUsers: allUsersList[index]);
                      }),
                ),
                onItemFound: (UserPublicProfile user, int index){
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

              );
            } else {
              return nil;
            }
          }),
    );
  }
}

