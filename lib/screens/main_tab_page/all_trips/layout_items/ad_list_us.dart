import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/generics/generic_bloc.dart';
import '../../../../blocs/generics/generic_state.dart';
import '../../../../blocs/generics/generics_event.dart';
import '../../../../models/custom_objects.dart';
import '../../../../repositories/trip_ad_repository.dart';
import '../../../../services/widgets/loading.dart';
import '../../../../size_config/size_config.dart';
import '../ad_card.dart';

/// Grid list for ads
class SliverGridAdList extends StatefulWidget {

  @override
  _SliverGridAdListState createState() => _SliverGridAdListState();
}

class _SliverGridAdListState extends State<SliverGridAdList> {

  late GenericBloc<TripAds,TripAdRepository>  tripAdBloc;

  int crossAxisCount = 2;

  @override
  void initState() {
    super.initState();
    tripAdBloc = BlocProvider.of<GenericBloc<TripAds,TripAdRepository>>(context);
    tripAdBloc.add(LoadingGenericData());
  }

  @override
  Widget build(BuildContext context) {
    if (SizeConfig.tablet) {
      setState(() {
        crossAxisCount = 4;
      });
    }
    return BlocBuilder<GenericBloc<TripAds,TripAdRepository>, GenericState>(
        builder: (BuildContext context, GenericState state) {
          if (state is LoadingState) {
            return Flexible(child: Loading());
          } else if (state is HasDataState) {
            final List<TripAds> adList = state.data as List<TripAds>;
            return SizedBox(
              height: SizeConfig.screenWidth*.55,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(adList.length, (int index) {
                  return AdCard(tripAds: adList[index]);
                }),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
