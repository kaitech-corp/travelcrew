import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories/trip_repositories/current_trip_repository.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../grouped_list_builder.dart';
import '../sliver_grid_view.dart';


/// Current trips
class CurrentTrips extends StatefulWidget {
  const CurrentTrips({Key? key}) : super(key: key);

  @override
  State<CurrentTrips> createState() => _CurrentTripsState();
}

class _CurrentTripsState extends State<CurrentTrips> {

  late GenericBloc<Trip,CurrentTripRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<Trip,CurrentTripRepository>>(context);//dependency injection
    bloc.add(LoadingGenericData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericBloc<Trip,CurrentTripRepository>, GenericState>(
      builder: (BuildContext context, GenericState state){
        if(state is LoadingState){
            return const Loading();
        } else if (state is HasDataState){
          final List<Trip> tripsData = state.data as List<Trip>;
        return SizeConfig.tablet ?
        SliverGridView(trips: tripsData, length: tripsData.length):
        GroupedListTripView(data: tripsData, isPast: false,);
        } else {
            return nil;
        }
      });
  }
}
