import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/favorite_trips_bloc/favorite_trip_event.dart';
import '../../../blocs/favorite_trips_bloc/favorite_trip_bloc.dart';
import '../../../blocs/favorite_trips_bloc/favorite_trip_state.dart';
import '../../../models/trip_model.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/loading.dart';
import '../../../size_config/size_config.dart';

import 'favorites_card.dart';

/// Favorites page
class FavoritesPage extends StatefulWidget {
  @override
  _FavoriteTripState createState() => _FavoriteTripState();

}

class _FavoriteTripState extends State<FavoritesPage> {
  FavoriteTripBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<FavoriteTripBloc>(context);
    bloc.add(LoadingData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<FavoriteTripBloc, TripState>(
        builder: (context, state){
          if(state is TripLoadingState){
            return Loading();
          } else if (state is TripHasDataState){
            List<Trip> trips = state.data;
            return Container(
              height: double.infinity,
              width: double.infinity,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0.0),
                  itemCount: trips != null ? trips.length : 0,
                  itemBuilder: (context, index){
                    var item = trips[index];
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      // Show a red background as the item is swiped away.
                      background: Container(
                        margin: EdgeInsets.all(SizeConfig.screenWidth*.05),
                        color: Colors.red,
                        child: const Align(alignment: Alignment.centerRight,child: const Icon(Icons.delete, color: Colors.white,)),),
                      key: Key(item.documentId),
                      onDismissed: (direction) {
                        setState(() {
                          trips.removeAt(index);
                          CloudFunction().removeFavoriteFromTrip(item.documentId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Tripped removed from favorites.")));
                      },
                      child: FavoritesCard(trip: trips[index]),
                    );
                  }),
            );
          } else {
            return Container();
          }
        });
  }
}

