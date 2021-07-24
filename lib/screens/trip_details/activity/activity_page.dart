import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/activities_bloc/activity_bloc.dart';
import 'package:travelcrew/blocs/activities_bloc/activity_event.dart';
import 'package:travelcrew/blocs/activities_bloc/activity_state.dart';
import 'package:travelcrew/models/activity_model.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/screens/trip_details/activity/activity_card.dart';

class ActivityPage extends StatefulWidget {

  final Trip trip;
  ActivityPage({this.trip});

  @override
  State<StatefulWidget> createState() {
    return _ActivityPageState();
  }
}

class _ActivityPageState extends State<ActivityPage> {

  ActivityBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<ActivityBloc>(context);
    bloc.add(LoadingActivityData());
    super.initState();
  }

  @override
  void dispose() {
    // bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, state){
              if(state is ActivityLoadingState){
                return Loading();
              } else if (state is ActivityHasDataState){
                List<ActivityData> activityList = state.data;
                return Container(
                  child: ListView.builder(
                      itemCount: activityList != null ? activityList.length : 0,
                      itemBuilder: (context, index){
                        return ActivityCard(activity: activityList[index],trip: widget.trip,);
                      }
                  ),
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

