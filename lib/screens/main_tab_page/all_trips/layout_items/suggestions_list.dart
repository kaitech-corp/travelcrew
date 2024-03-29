import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories/trip_repositories/all_trip_suggestion_repository.dart';
import '../../../../services/functions/tc_functions.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';

/// Grid list for trip suggestions
class SliverGridTripSuggestionList extends StatefulWidget {
  const SliverGridTripSuggestionList({Key? key}) : super(key: key);

  @override
  State<SliverGridTripSuggestionList> createState() =>
      _SliverGridTripSuggestionListState();
}

class _SliverGridTripSuggestionListState
    extends State<SliverGridTripSuggestionList> {
  late GenericBloc<Trip, AllTripsSuggestionRepository> bloc;

  int crossAxisCount = 2;

  List<int> randomList = TCFunctions().randomList();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GenericBloc<Trip, AllTripsSuggestionRepository>>(
        context);
    bloc.add(LoadingGenericData());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericBloc<Trip, AllTripsSuggestionRepository>,
        GenericState>(builder: (BuildContext context, GenericState state) {
      if (state is LoadingState) {
        return const Flexible(child: Loading());
      } else if (state is HasDataState) {
        final List<Trip> tripList = state.data as List<Trip>;
        return SizedBox(
          height: SizeConfig.screenWidth * .2,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.generate(5, (int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: SizeConfig.screenWidth * .4,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.blue[50]),
                  child: Center(
                      child: Text(tripList[randomList[index]].location,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: responsiveTextStyleSuggestions(context))),
                ),
              );
            }),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}
