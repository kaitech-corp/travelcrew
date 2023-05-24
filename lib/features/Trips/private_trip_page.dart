import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../repositories/trip_repositories/private_trip_repository.dart';
import '../../../../services/functions/tc_functions.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../models/trip_model/trip_model.dart';
import 'components/grouped_list_builder.dart';
import 'components/sliver_grid_view.dart';
import 'logic/logic.dart';


/// Private trips
class PrivateTrips extends StatefulWidget {
  const PrivateTrips({Key? key, required this.past}) : super(key: key);

  final bool past;

  @override
  State<PrivateTrips> createState() => _PrivateTripsState();
}

class _PrivateTripsState extends State<PrivateTrips> {
  late GenericBloc<Trip, PrivateTripRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<Trip, PrivateTripRepository>>(context);
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
    return BlocBuilder<GenericBloc<Trip, PrivateTripRepository>, GenericState>(
        builder: (BuildContext context, GenericState state) {
      if (state is LoadingState) {
        return const Loading();
      } else if (state is HasDataState) {
        final List<Trip> tripsData = state.data as List<Trip>;
        final List<Trip> trips =
           getCurrentPrivateTrips(tripsData, widget.past);
        return SizeConfig.tablet
            ? SliverGridView(trips: trips, length: trips.length)
            : GroupedListTripView(
                data: trips,
                isPast: true,
              );
      } else {
        return nil;
      }
    });
  }
}
