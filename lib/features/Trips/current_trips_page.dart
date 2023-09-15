import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../repositories/trip_repositories/current_trip_repository.dart';
import '../../../../repositories/trip_repositories/private_trip_repository.dart';
import '../../../../services/theme/text_styles.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../../models/trip_model/trip_model.dart';
import 'components/grouped_list_builder.dart';
import 'components/sliver_grid_view.dart';
import 'logic/logic.dart';
import 'private_trip_page.dart';

class CurrentTrips extends StatefulWidget {
  const CurrentTrips({super.key});

  @override
  State<CurrentTrips> createState() => _CurrentTripsState();
}

class _CurrentTripsState extends State<CurrentTrips> {
  late GenericBloc<Trip, CurrentTripRepository> bloc;
  bool isPast = false;

  void toggleIsPast() {
    setState(() {
      isPast = !isPast;
    });
  }

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
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                        child: Text(
                          'Public',
                          style: titleMedium(context)
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: toggleIsPast,
                        child: Text(isPast ? 'Show Upcoming' : 'Show All'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(height: 2, color: Colors.grey[200]),
                  ),
                  Expanded(
                    flex: 2,
                    child: GroupedListTripView(
                      data: isPast ? tripsData: getFilteredTrips(tripsData),
                      isPast: isPast,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                    child: Text(
                      'Private',
                      style: titleMedium(context)
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(height: 2, color: Colors.grey[200]),
                  ),
                  Expanded(
                    flex: 2,
                    child: BlocProvider<GenericBloc<Trip, PrivateTripRepository>>(
                      create: (BuildContext context) =>
                          GenericBloc<Trip, PrivateTripRepository>(
                              repository: PrivateTripRepository()),
                      child: PrivateTrips(past: isPast),
                    ),
                  ),
                ],
              );
      } else {
        return nil;
      }
    });
  }
}
