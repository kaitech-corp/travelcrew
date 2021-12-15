import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import '../../../../blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trip_event.dart';
import '../../../../blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trip_state.dart';
import '../../../../blocs/crew_trips_bloc/current_crew_trips_bloc/current_crew_trips_bloc.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';

import '../grouped_list_builder.dart';
import '../sliver_grid_view.dart';


/// Current trips
class CurrentTrips extends StatefulWidget{

  @override
  _CurrentTripsState createState() => _CurrentTripsState();
}

class _CurrentTripsState extends State<CurrentTrips>{
  CurrentCrewTripBloc blocCurrent;

  @override
  void initState() {
    blocCurrent = BlocProvider.of<CurrentCrewTripBloc>(context);
    blocCurrent.add(LoadingData());
    super.initState();
  }


  @override
  void didChangeDependencies() {
    blocCurrent = BlocProvider.of<CurrentCrewTripBloc>(context);
    blocCurrent.add(LoadingData());
    context.dependOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  // @override
  // void dispose() {
  //   blocCurrent.close();
  //   super.dispose();
  // }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentCrewTripBloc, TripState>(
      builder: (context, state){
        if(state is TripLoadingState){
            return Loading();
        } else if (state is TripHasDataState){
        return SizeConfig.tablet ?
        SliverGridView(trips: state.data, length: state.data.length):
        GroupedListTripView(data: state.data, isPast: false,);
        } else {
            return nil;
        }
      });
  }
}