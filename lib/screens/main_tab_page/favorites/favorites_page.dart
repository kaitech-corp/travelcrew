import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/generics/generic_bloc.dart';
import '../../../blocs/generics/generic_state.dart';
import '../../../blocs/generics/generics_event.dart';

import '../../../models/trip_model.dart';
import '../../../repositories/trip_repositories/favorite_trip_repository.dart';
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
  late GenericBloc<Trip,FavoriteTripRepository> bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<GenericBloc<Trip,FavoriteTripRepository>>(context);
    bloc.add(LoadingGenericData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<GenericBloc<Trip,FavoriteTripRepository>, GenericState>(
        builder: (BuildContext context, GenericState state){
          if(state is LoadingState){
            return Loading();
          } else if (state is HasDataState){
            final List<Trip> trips = state.data as List<Trip>;
            return SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: ListView.builder(
                  padding: const EdgeInsets.all(0.0),
                  itemCount: trips.length,
                  itemBuilder: (BuildContext context, int index){
                    final Trip item = trips[index];
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      // Show a red background as the item is swiped away.
                      background: Container(
                        margin: EdgeInsets.all(SizeConfig.screenWidth*.05),
                        color: Colors.red,
                        child: const Align(alignment: Alignment.centerRight,child: Icon(Icons.delete, color: Colors.white,)),),
                      key: Key(item.documentId),
                      onDismissed: (DismissDirection direction) {
                        setState(() {
                          trips.removeAt(index);
                          CloudFunction().removeFavoriteFromTrip(item.documentId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tripped removed from favorites.')));
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

