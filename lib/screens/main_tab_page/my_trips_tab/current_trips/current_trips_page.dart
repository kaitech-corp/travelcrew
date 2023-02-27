import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories/trip_repositories/current_trip_repository.dart';
import '../../../../repositories/trip_repositories/private_trip_repository.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../grouped_list_builder.dart';
import '../private_trips/private_trip_page.dart';
import '../sliver_grid_view.dart';

/// Current trips
class CurrentTrips extends StatefulWidget {
  const CurrentTrips({Key? key}) : super(key: key);

  @override
  State<CurrentTrips> createState() => _CurrentTripsState();
}

class _CurrentTripsState extends State<CurrentTrips> {
  late GenericBloc<Trip, CurrentTripRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<Trip, CurrentTripRepository>>(
        context); //dependency injection
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
    return BlocBuilder<GenericBloc<Trip, CurrentTripRepository>, GenericState>(
        builder: (BuildContext context, GenericState state) {
      if (state is LoadingState) {
        return const Loading();
      } else if (state is HasDataState) {
        final List<Trip> tripsData = state.data as List<Trip>;
        return SizeConfig.tablet
            ? SliverGridView(trips: tripsData, length: tripsData.length)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    child: Text(
                      'Public',
                      style: titleMedium(context),
                    ),
                  ),
                  Expanded(
                      child: GroupedListTripView(
                    data: tripsData,
                    isPast: false,
                  )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    child: Text(
                      'Private',
                      style: titleMedium(context),
                    ),
                  ),
                   Expanded(
                      // ignore: always_specify_types
                      child: BlocProvider(
              create: (BuildContext context) =>
                  GenericBloc<Trip, PrivateTripRepository>(
                      repository: PrivateTripRepository()),child: const PrivateTrips(past: false),),),
                ],
              );
      } else {
        return nil;
      }
    });
  }
}
