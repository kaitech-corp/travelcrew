import 'package:flutter/material.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';

class AllTripsTextSection extends StatelessWidget {


  AllTripsTextSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ImageLayout("assests/images/barcelona.jpg"),
            const ListTile(
              leading: Icon(Icons.album),
              title: Text('The Enchanted Nightingale'),
              subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
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