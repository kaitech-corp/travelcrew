import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';
import '../../../services/database.dart';
import '../../../services/functions/tc_functions.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/loading.dart';
import '../../models/activity_model/activity_model.dart';
import '../../models/trip_model/trip_model.dart';
import 'components/activity_card.dart';
import 'logic/activity_repository.dart';


class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.trip});

  final Trip trip;

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late GenericBloc<ActivityModel, ActivityRepository> bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GenericBloc<ActivityModel, ActivityRepository>>(context);
    bloc.add(LoadingGenericData());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<GenericBloc<ActivityModel, ActivityRepository>, GenericState>(
          builder: (BuildContext context, GenericState state) {
            if (state is LoadingState) {
              return const Loading();
            } else if (state is HasDataState) {
              final List<ActivityModel> activityList = state.data as List<ActivityModel>;
              return GroupedListView<ActivityModel, String>(
                elements: activityList,
                groupBy: (ActivityModel activity) => DateTime(
                  activity.startDateTimestamp!.year,
                  activity.startDateTimestamp!.month,
                  activity.startDateTimestamp!.day,
                ).toString(),
                groupSeparatorBuilder: (String activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Center(
                    child: Text(
                      TCFunctions().dateToMonthDayFromTimestamp(Timestamp.fromDate(DateTime.parse(activity))),
                      style: headlineSmall(context)!.copyWith(color: Colors.black54),
                    ),
                  ),
                ),
                itemComparator: (ActivityModel a, ActivityModel b) => a.startTime.compareTo(b.startTime),
                itemBuilder: (BuildContext context, ActivityModel activity) {
                  return ActivityCard(
                    activity: activity,
                    trip: widget.trip,
                  );
                },
              );
            } else {
              return Container();
            }
          },
        ),
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
