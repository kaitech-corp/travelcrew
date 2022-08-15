import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../models/activity_model.dart';
import '../../../models/trip_model.dart';
import '../../../repositories/activity_repository.dart';
import '../../../services/database.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/widgets/loading.dart';
import 'activity_card.dart';

class ActivityPage extends StatefulWidget {

  final Trip trip;
  ActivityPage({required this.trip});

  @override
  State<StatefulWidget> createState() {
    return _ActivityPageState();
  }
}

class _ActivityPageState extends State<ActivityPage> {

  late GenericBloc<ActivityData,ActivityRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<ActivityData,ActivityRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<GenericBloc<ActivityData,ActivityRepository>, GenericState>(
            builder: (context, state){
              if(state is LoadingState){
                return Loading();
              } else if (state is HasDataState<ActivityData>){
                List<ActivityData> activityList = state.data;
            return Container(
                  child:
                    GroupedListView<ActivityData, String>(
                      elements: activityList,
                      groupBy: (activity) => DateTime(
                          activity.startDateTimestamp!.toDate().year,
                          activity.startDateTimestamp!.toDate().month,
                          activity.startDateTimestamp!.toDate().day,).toString(),
                      order: GroupedListOrder.ASC,
                      groupSeparatorBuilder: (activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Center(
                            child: Text(
                              TCFunctions().dateToMonthDayFromTimestamp(
                                  Timestamp.fromDate(DateTime.parse(activity))),
                              style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.black54),)),
                      ),
                      itemComparator: (a,b) => (a.startTime!.compareTo(b.startTime!)),
                      itemBuilder: (context, activity){
                        return ActivityCard(activity: activity,trip: widget.trip,);
                      },
                    )
                );
              } else {
                return Container();
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigationService.navigateTo(AddNewActivityRoute, arguments: widget.trip);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

