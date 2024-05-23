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
import '../../models/trip_model/trip_model.dart';
import '../Explore/followers/user_following_list_page.dart';
import 'components/user_card.dart';

class AllUserPage extends StatelessWidget {
  const AllUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TC Members',
          style: titleLarge(context),
        ),
        // flexibleSpace: const AppBarGradient(),
      ),
      body: const UserSearchBar(displayChild: false,),
    );
  }
}

class UserSearchBar extends StatefulWidget {
  const UserSearchBar({super.key, this.placeholder, this.trip, required this.displayChild});
  final Widget? placeholder;
  final bool displayChild;
  final Trip? trip;

  @override
  State<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends State<UserSearchBar> {
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

    return BlocBuilder<GenericBloc<UserPublicProfile, AllUserRepository>,
            GenericState>(
        // bloc: blocCurrent,
        builder: (BuildContext context, GenericState state) {
      if (state is LoadingState) {
        return const Loading();
      } else if (state is HasDataState) {
        final List<UserPublicProfile> allUsersList =
            state.data as List<UserPublicProfile>;
        allUsersSearchList = allUsersList;
        return FlappySearchBar<UserPublicProfile>(
          onSearch: userSearchList,
          textStyle: titleMedium(context)!,
          hintText: 'Search',
          placeHolder: widget.placeholder,
          // TODO: Add recent search in placeholder
          onItemFound: (UserPublicProfile user, int index) {
            return widget.displayChild ? UserCardLayout(user: user, trip: widget.trip!) : TCUserCard(user: user);
          },
        );
      } else {
        return nil;
      }
    });
  }
}
