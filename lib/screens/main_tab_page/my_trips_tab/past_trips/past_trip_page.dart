import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories_v2/trip_repositories/past_trip_repository.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../grouped_list_builder.dart';
import '../sliver_grid_view.dart';


/// Past Trips
class PastTrips extends StatefulWidget{

  @override
  _PastTripsState createState() => _PastTripsState();

}

class _PastTripsState extends State<PastTrips>{
  GenericBloc<Trip,PastTripRepository> bloc;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<GenericBloc<Trip,PastTripRepository>>(context);//dependency injection
    bloc.add(LoadingGenericData());
    context.dependOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<GenericBloc<Trip,PastTripRepository>, GenericState>(
        builder: (context, state){
          if(state is LoadingState){
            return Loading();
          } else if (state is HasDataState){
            return SizeConfig.tablet ?
            SliverGridView(trips: state.data, length: state.data.length):
            GroupedListTripView(data: state.data,isPast: true,);
          } else {
            return Container();
          }
        });
  }

}

