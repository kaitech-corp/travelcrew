import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trips_bloc.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trip_state.dart';
import 'package:travelcrew/blocs/crew_trips_bloc/private_crew_trips_bloc/private_crew_trip_event.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/services/widgets/loading.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../grouped_list_builder.dart';
import '../sliver_grid_view.dart';

class PrivateTrips extends StatefulWidget{

  @override
  _PrivateTripsState createState() => _PrivateTripsState();

}

class _PrivateTripsState extends State<PrivateTrips>{
  PrivateTripBloc bloc;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<PrivateTripBloc>(context);
    bloc.add(LoadingData());
    context.dependOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  // @override
  // void dispose() {
  //  bloc.close();
  //   super.dispose();
  // }


  @override
  Widget build(BuildContext context) {

    return BlocBuilder<PrivateTripBloc, TripState>(
        builder: (context, state){
          if(state is TripLoadingState){
            return Loading();
          } else if (state is TripHasDataState){
            return SizeConfig.tablet ?
            SliverGridView(trips: state.data, length: state.data.length):
            Provider<List<Trip>>.value(
                value: state.data,
                updateShouldNotify: (oldData, newData) => oldData != newData,
                child:
                GroupedListTripView(data: state.data, isPast: true,)
            )
            ;
          } else {
            return Container();
          }
        });
  }

}