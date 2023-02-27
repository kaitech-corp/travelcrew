import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/public_profile_bloc/public_profile_bloc.dart';
import '../../../models/trip_model.dart';
import '../../../repositories/user_profile_repository.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import '../../menu_screens/main_menu.dart';
import 'explore_basic_layout.dart';

/// Basic layout for Explore page.
class ExploreBasic extends StatelessWidget {
  const ExploreBasic({Key? key, required this.trip}) : super(key: key);

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[
      'Explore',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        drawer: BlocProvider<PublicProfileBloc>(
          create: (BuildContext context) => PublicProfileBloc(
              profileRepository: PublicProfileRepository()..refresh(userService.currentUserID)),
          child: const MenuDrawer(),),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: canvasColor,
            title: Tooltip(
              message: trip.tripName,
              child: Text(trip.tripName.toUpperCase(),
                  style: SizeConfig.tablet ?
                  headlineMedium(context):
                  headlineSmall(context)),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ],
            bottom: TabBar(
              labelStyle: SizeConfig.tablet ? headlineMedium(context) : titleMedium(context),
              isScrollable: true,
              tabs: <Tab>[
                for (final String tab in tabs) Tab(text: tab),
              ],
            ),
          ),
          body: ExploreBasicLayout(tripDetails: trip,),
      ),
    );
  }
}
