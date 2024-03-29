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
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/loading.dart';
import 'activity_card.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key, required this.trip}) : super(key: key);

  final Trip trip;

  @override
  State<StatefulWidget> createState() {
    return _ActivityPageState();
  }
}

class _ActivityPageState extends State<ActivityPage> {
  late GenericBloc<ActivityData, ActivityRepository> bloc;

  @override
  void initState() {
    bloc =
        BlocProvider.of<GenericBloc<ActivityData, ActivityRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
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
        body: BlocBuilder<GenericBloc<ActivityData, ActivityRepository>,
            GenericState>(builder: (BuildContext context, GenericState state) {
          if (state is LoadingState) {
            return const Loading();
          } else if (state is HasDataState) {
            final List<ActivityData> activityList =
                state.data as List<ActivityData>;
            return GroupedListView<ActivityData, String>(
              elements: activityList,
              groupBy: (ActivityData activity) => DateTime(
                activity.startDateTimestamp.toDate().year,
                activity.startDateTimestamp.toDate().month,
                activity.startDateTimestamp.toDate().day,
              ).toString(),
              groupSeparatorBuilder: (String activity) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Center(
                    child: Text(
                  TCFunctions().dateToMonthDayFromTimestamp(
                      Timestamp.fromDate(DateTime.parse(activity))),
                  style: headlineSmall(context)!
                      .copyWith(color: Colors.black54),
                )),
              ),
              itemComparator: (ActivityData a, ActivityData b) =>
                  a.startTime.compareTo(b.startTime),
              itemBuilder: (BuildContext context, ActivityData activity) {
                return ActivityCard(
                  activity: activity,
                  trip: widget.trip,
                );
              },
            );
          } else {
            return Container();
          }
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigationService.navigateTo(AddNewActivityRoute,
                arguments: widget.trip);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
