import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_event.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/past_crew_trips_bloc/past_crew_trips_state.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../grouped_list_builder.dart';
import '../sliver_grid_view.dart';

class PastTrips extends StatefulWidget{

  @override
  _PastTripsState createState() => _PastTripsState();

}

class _PastTripsState extends State<PastTrips>{
  PastCrewTripBloc bloc;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<PastCrewTripBloc>(context);
    bloc.add(LoadingData());
    context.dependOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  // @override
  // void dispose() {
  //   bloc.close();
  //   super.dispose();
  // }



  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PastCrewTripBloc, TripState>(
        builder: (context, state){
          if(state is TripLoadingState){
            return Loading();
          } else if (state is TripHasDataState){
            return SizeConfig.tablet ?
            SliverGridView(trips: state.data, length: state.data.length):
            GroupedListTripView(data: state.data,isPast: true,);
          } else {
            return Container();
          }
        });
  }

}

