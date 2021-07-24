import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/public_profile_bloc/public_profile_bloc.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/repositories/user_profile_repository.dart';
import 'package:travelcrew/screens/menu_screens/main_menu.dart';
import 'package:travelcrew/screens/trip_details/explore/explore_basic_layout.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';

class ExploreBasic extends StatelessWidget {

  final Trip trip;
  ExploreBasic({this.trip});

  @override
  Widget build(BuildContext context) {
    List<String> tabs = [
      'Explore',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        drawer: BlocProvider(
          create: (context) => PublicProfileBloc(
              profileRepository: PublicProfileRepository()..refresh(userService.currentUserID)),
          child: MenuDrawer(),),
          appBar: AppBar(
            centerTitle: true,
            title: Text('${trip.tripName}'.toUpperCase(),style: SizeConfig.tablet ? Theme.of(context).textTheme.headline5: Theme.of(context).textTheme.headline6),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ],
            bottom: TabBar(
              labelStyle: SizeConfig.tablet ? Theme.of(context).textTheme.headline5 : Theme.of(context).textTheme.subtitle1,
              isScrollable: true,
              tabs: [
                for (final tab in tabs) Tab(text: tab),
              ],
            ),
          ),
          body: ExploreBasicLayout(tripDetails: trip,),
      ),
    );
  }
}