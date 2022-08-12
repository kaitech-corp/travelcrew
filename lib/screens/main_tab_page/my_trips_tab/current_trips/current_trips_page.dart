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
class CurrentTrips extends StatefulWidget{

  @override
  _CurrentTripsState createState() => _CurrentTripsState();
}

class _CurrentTripsState extends State<CurrentTrips>{
  late GenericBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<Trip,CurrentTripRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
  }


  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<GenericBloc<Trip,CurrentTripRepository>>(context);//dependency injection
    bloc.add(LoadingGenericData());
    context.dependOnInheritedWidgetOfExactType();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenericBloc<Trip,CurrentTripRepository>, GenericState>(
      // bloc: bloc,
      builder: (context, state){
        if(state is LoadingState){
            return Loading();
        } else if (state is HasDataState<Trip>){
        return SizeConfig.tablet ?
        SliverGridView(trips: state.data, length: state.data.length):
        GroupedListTripView(data: state.data, isPast: false,);
        } else {
            return nil;
        }
      });
  }
}