import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
//import 'package:webview_flutter/webview_flutter.dart';

class FlightItemLayout extends StatelessWidget {

  final FlightData flight;
  FlightItemLayout({this.flight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
//                ImageLayout(_text ?? "assests/images/barcelona.jpg"),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('${flight.displayName}'),
                      Text('${flight.airline}'),
                      Row (
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Depart: ${flight.departureDate}'),
                              Text('Airport'),
                              Text('D: ${flight.departureDateDepartTime}'),
                              Text('A: ${flight.departureDateArrivalTime}'),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Return: ${flight.returnDate}'),
                              Text('Airport'),
                              Text('D: ${flight.returnDateDepartTime}'),
                              Text('A: ${flight.returnDateArrivalTime}'),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('View'),
                      onPressed: () { /* ... */ },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
}
