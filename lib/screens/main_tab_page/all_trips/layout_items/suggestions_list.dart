import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories/trip_repositories/all_trip_suggestion_repository.dart';
import '../../../../services/functions/tc_functions.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';

/// Grid list for trip suggestions
class SliverGridTripSuggestionList extends StatefulWidget {

  @override
  _SliverGridTripSuggestionListState createState() => _SliverGridTripSuggestionListState();
}

class _SliverGridTripSuggestionListState extends State<SliverGridTripSuggestionList> {

  GenericBloc<Trip,AllTripsSuggestionRepository>  bloc;

  int crossAxisCount = 2;

  List<int> randomList = TCFunctions().randomList();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GenericBloc<Trip,AllTripsSuggestionRepository>>(context);
    bloc.add(LoadingGenericData());
  }

  @override
  Widget build(BuildContext context) {
    if (SizeConfig.tablet) {
      setState(() {
        crossAxisCount = 4;
      });
    }
    return BlocBuilder<GenericBloc<Trip,AllTripsSuggestionRepository>, GenericState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return Flexible(fit:FlexFit.loose,child: Loading());
          } else if (state is HasDataState) {
            List<Trip> tripList = state.data;
            return SizedBox(
              height: SizeConfig.screenWidth*.2,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(5),
                        width: SizeConfig.screenWidth*.4,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue[50]
                        ),
                        child: Center(
                            child: Text(tripList[randomList[index]].location,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle1,)),
                    ),
                  );
                }
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}