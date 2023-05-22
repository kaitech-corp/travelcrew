import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/trip_model.dart';
import '../../../../repositories/trip_repositories/past_trip_repository.dart';
import '../../../../repositories/trip_repositories/private_trip_repository.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../grouped_list_builder.dart';
import '../private_trips/private_trip_page.dart';
import '../sliver_grid_view.dart';

/// Past Trips
class PastTrips extends StatefulWidget {
  const PastTrips({Key? key}) : super(key: key);

  @override
  State<PastTrips> createState() => _PastTripsState();
}

class _PastTripsState extends State<PastTrips> {
  late GenericBloc<Trip, PastTripRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<Trip, PastTripRepository>>(
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
    return BlocBuilder<GenericBloc<Trip, PastTripRepository>, GenericState>(
        builder: (BuildContext context, GenericState state) {
      if (state is LoadingState) {
        return const Loading();
      } else if (state is HasDataState) {
        final List<Trip> tripsData = state.data as List<Trip>;
        return SizeConfig.tablet
            ? SliverGridView(trips: tripsData, length: state.data.length)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    child: Text(
                      'Public',
                      style: titleMedium(context)?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(height: 2,color:Colors.grey[200]),
                  ),
                  Expanded(
                    flex: 2,
                      child: GroupedListTripView(
                    data: tripsData,
                    isPast: false,
                  )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    child: Text(
                      'Private',
                      style: titleMedium(context)?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(height: 2,color:Colors.grey[200]),
                  ),
                  Expanded(
                    flex: 2,
                      // ignore: always_specify_types
                      child: BlocProvider(
              create: (BuildContext context) =>
                  GenericBloc<Trip, PrivateTripRepository>(
                      repository: PrivateTripRepository()),child: const PrivateTrips(past: true),),),
                ],
              );
      } else {
        return Container();
      }
    });
  }
}
