import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_event.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_state.dart';
import 'package:travelcrew/screens/main_tab_page/crew_trips/tappable_crew_trip_grid.dart';
import 'package:travelcrew/size_config/size_config.dart';

import '../../../services/widgets/loading.dart';
import '../crew_trip_card.dart';

class PastTrips extends StatefulWidget{

  @override
  _PastTripsState createState() => _PastTripsState();

}

class _PastTripsState extends State<PastTrips>{
  PastCrewTripBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<PastCrewTripBloc>(context);
    bloc.add(LoadingData());
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PastCrewTripBloc, TripState>(
      // bloc: blocCurrent,
        builder: (context, state){
          if(state is TripLoadingState){
        return Loading();
          } else if (state is TripHasDataState){
        return SizeConfig.tablet ?
            SliverGridView(trips: state.data, length: state.data.length):
            ListView.builder(
              padding: EdgeInsets.all(0.0),
              itemCount: state.data.length ?? 0,
              itemBuilder: (context, index){
                return CrewTripCard(trip: state.data[index]);
              },
            );
          } else {
            return Container();
          }
        });
  }

}