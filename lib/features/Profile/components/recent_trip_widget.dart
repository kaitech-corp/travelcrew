//Recent Trip tile
import 'package:flutter/material.dart';

import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/loading.dart';
import '../logic/logic.dart';

class RecentTripTile extends StatelessWidget{

  const RecentTripTile({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trip>>(
        builder: (BuildContext context, AsyncSnapshot<List<Trip>?> streamData){
          if(streamData.hasData){
            final List<Trip> trips = streamData.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (trips.length > 10) ? 10 : trips.length,
              itemBuilder: (BuildContext context, int index){
                final Trip trip = trips[index];
                return InkWell(
                  onTap: (){
                    navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: (trip.urlToImage?.isNotEmpty ?? false) ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          trip.urlToImage!,
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        )):
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                              Colors.blue,
                              Colors.lightBlueAccent
                            ]
                        ),
                      ),
                      height: 125,
                      width: 125,
                      child: ListTile(
                        title: Text(trip.tripName,style: titleMedium(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                        subtitle: Text(trip.location ?? '',style: titleSmall(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ),
                  ),
                );
              });
          } else {
            return const Loading();
          }
        },
        stream: pastCrewTripsCustom(uid),
    );
  }

}