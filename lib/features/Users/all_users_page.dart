import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';


import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';

import '../../../../repositories/all_users_repository.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/appbar_gradient.dart';
import '../../../../services/widgets/loading.dart';
import '../../models/public_profile_model/public_profile_model.dart';
import 'components/user_card.dart';

class AllUserPage extends StatefulWidget {
  const AllUserPage({super.key});

  @override
  State<AllUserPage> createState() => _AllUserPageState();
}

class _AllUserPageState extends State<AllUserPage> {
  late GenericBloc<UserPublicProfile, AllUserRepository> bloc;

  final ScrollController controller = ScrollController();
  bool _isSearching = false;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<UserPublicProfile, AllUserRepository>>(
        context);
    bloc.add(LoadingGenericData());
    super.initState();
  }

  void pressedSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    late List<UserPublicProfile> allUsersSearchList;

    Future<List<UserPublicProfile>> userSearchList(String name) async {
      final String val = name.toLowerCase();

      final List<UserPublicProfile> results = allUsersSearchList
          .where((UserPublicProfile user) =>
              user.displayName.toLowerCase().contains(val))
          .toList();
      return results;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TC Members',
          style: headlineSmall(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              pressedSearch();
            },
          )
        ],
        flexibleSpace: const AppBarGradient(),
      ),
      body: BlocBuilder<GenericBloc<UserPublicProfile, AllUserRepository>,
              GenericState>(
          // bloc: blocCurrent,
          builder: (BuildContext context, GenericState state) {
        if (state is LoadingState) {
          return const Loading();
        } else if (state is HasDataState) {
          final List<UserPublicProfile> allUsersList =
              state.data as List<UserPublicProfile>;
          allUsersSearchList = allUsersList;
          return _isSearching
              ? FlappySearchBar<UserPublicProfile>(
                  onSearch: userSearchList,
                  textStyle: titleMedium(context)!,
                  placeHolder: DraggableScrollbar.semicircle(
                    controller: controller,
                    child: ListView.builder(
                        controller: controller,
                        itemCount: allUsersList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return TCUserCard(user: allUsersList[index]);
                        }),
                  ),
                  onItemFound: (UserPublicProfile user, int index) {
                    return TCUserCard(user: user);
                  },
                )
              : DraggableScrollbar.semicircle(
                  controller: controller,
                  child: ListView.builder(
                      controller: controller,
                      itemCount: allUsersList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TCUserCard(user: allUsersList[index]);
                      }),
                );
        } else {
          return nil;
        }
      }),
    );
  }
}
