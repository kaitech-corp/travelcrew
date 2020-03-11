import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/main_tab_page/all_trips_page/tappable_trip_card.dart';
import '../../loading.dart';

class TripList extends StatefulWidget {
  @override
  _TripListState createState() => _TripListState();

}

class _TripListState extends State<TripList> {
  @override
  Widget build(BuildContext context) {
    bool loading = true;
    final user = Provider.of<UserProfile>(context);
    final trips = Provider.of<List<Trip>>(context);
    List<Trip> trips2 = List();
    
    createList() async {
      if(trips != null) {
        setState(() {
          loading = false;
        });

      }
      
      var trips3 = trips.where((trip) => !trip.accessUsers.contains(user.uid));
      trips3.forEach((f) => trips2.add(f));
    }
    var createList2 = createList();
    
    return loading ? Loading() : ListView.builder(
        itemCount: trips2 != null ? trips2.length : 0,
        itemBuilder: (context, index){
          return TappableTripCard(trip: trips2[index]);
        });
  }
}

