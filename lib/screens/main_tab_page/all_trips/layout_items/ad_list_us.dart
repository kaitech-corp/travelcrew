import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/custom_objects.dart';
import '../../../../repositories/trip_ad_repository.dart';
import '../../../../services/database.dart';
import '../../../../size_config/size_config.dart';
import '../ad_card.dart';

/// Grid list for ads
class SliverGridAdList extends StatefulWidget {
  const SliverGridAdList({Key? key}) : super(key: key);

  @override
  State<SliverGridAdList> createState() => _SliverGridAdListState();
}

class _SliverGridAdListState extends State<SliverGridAdList> {
  late GenericBloc<TripAds, TripAdRepository> tripAdBloc;

  int crossAxisCount = 2;

  @override
  void initState() {
    super.initState();
    tripAdBloc =
        BlocProvider.of<GenericBloc<TripAds, TripAdRepository>>(context);
    tripAdBloc.add(LoadingGenericData());
  }

  @override
  Widget build(BuildContext context) {
    if (SizeConfig.tablet) {
      setState(() {
        crossAxisCount = 4;
      });
    }
    return FutureBuilder<List<DestinationModel>>(
        future: DatabaseService().getDestinations(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DestinationModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List<DestinationModel> destinations = snapshot.data!;
            print(destinations.length);
            return SizedBox(
              height: SizeConfig.screenWidth * .55,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    List<Widget>.generate(destinations.length, (int index) {
                  return AdCard(tripAds: destinations[index]);
                }),
              ),
            );
          } else {
            return const Text('No destinations found');
          }
          // return BlocBuilder<GenericBloc<DestinationModel,DestinationRepository>, GenericState>(
          //     builder: (BuildContext context, GenericState state) {
          //       if (state is LoadingState) {
          //         return const Flexible(child: Loading());
          //       } else if (state is HasDataState) {
          //         final List<DestinationModel> adList = state.data as List<DestinationModel>;
          //         return SizedBox(
          //           height: SizeConfig.screenWidth*.55,
          //           child: ListView(
          //             scrollDirection: Axis.horizontal,
          //             children: List<Widget>.generate(adList.length, (int index) {
          //               return AdCard(tripAds: adList[index]);
          //             }),
          //           ),
          //         );
          //       } else {
          //         return Container();
          //       }
          //     });
          // }
        });
  }
}
