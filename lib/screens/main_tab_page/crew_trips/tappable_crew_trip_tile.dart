import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/explore/stream_to_explore.dart';


class TappableCrewTripTile extends StatelessWidget {

  final Trip trip;

  TappableCrewTripTile({this.trip});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final user = Provider.of<User>(context);
    return Container(
      height: size.height*.15,
      width: double.infinity,
      margin: EdgeInsets.only(left: 10, bottom: 20, top: 20, right: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(
            offset: Offset(0, 10),
            blurRadius: 33,
            color: Color(Colors.blueGrey.value).withOpacity(.84),
            spreadRadius: 5,
          )
          ]),
      child: Container(
//        decoration: BoxDecoration(
//            image: DecorationImage(
//              image: AssetImage('assets/images/travelPics.png'),
//              alignment: Alignment.topRight,
//            ),
//            borderRadius: BorderRadius.only(topRight: Radius.circular(30),bottomRight: Radius.circular(30))
//        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(trip.location != null ? trip.location : 'Trip Name',style: TextStyle(fontSize: 24),),
              subtitle: Text(trip.travelType != null ? "${trip.travelType}" : "",
                textAlign: TextAlign.start,),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StreamToExplore(trip: trip,)),
                );

              },
            ),
            Expanded(
              child: Container(

                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${ownerName(user.uid)}'),
                          Text(trip.startDate != null ? '${trip.startDate} - ${trip.endDate}' : 'Dates'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('${trip.accessUsers.length} '),
                          Icon(Icons.people)
                        ],
                      ),
                    ],
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
  String ownerName(String uid){
    if (trip.ownerID == uid){
      return 'You';
    }else {
      return trip.displayName;
    }
  }

}