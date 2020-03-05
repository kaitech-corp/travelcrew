import 'package:flutter/material.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';

class TripCard extends StatelessWidget {
  final String _text;

  TripCard(this._text);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ImageLayout(_text ?? "assests/images/barcelona.jpg"),
            const ListTile(
              title: Text('Trip Name'),
              subtitle: Text('Owner'),
//              isThreeLine: true,
            ),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('Join'),
                  onPressed: () {
                    /* ... */
                  },
                ),
                FlatButton(
                  child: Icon(Icons.favorite),
                  onPressed: () {
                    /* ... */
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}