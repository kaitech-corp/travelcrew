import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/explore/explore.dart';
import 'package:travelcrew/services/database.dart';
//import 'package:webview_flutter/webview_flutter.dart';

class ActivityItemLayout extends StatelessWidget {

  final ActivityData activity;
  final String tripDocID;
  ActivityItemLayout({this.activity, this.tripDocID});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return Center(
      child: Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Explore()),
            );
            print('Card tapped.');
          },
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
                      Text('${activity.activityType}'),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),
                      Text('Comment: ${activity.comment}'),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Owner: ${activity.displayName}'),
                          Text('Votes: ${activity.vote}'),
                        ],
                      ),
                      Column (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (activity.link.isNotEmpty) Text('Link attached'),
                          if (activity.urlToImage.isNotEmpty) ImageLayout(activity.urlToImage),
                        ],
                      )
                    ],
                  ),
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: favorite(user.uid),
                      onPressed: () {
                        String fieldID = activity.fieldID;
                        String uid = user.uid;
                        if (!activity.voters.contains(user.uid)) {
                      return DatabaseService(tripDocID: tripDocID).addVoteToActivity(uid, fieldID);
                        } else {
                      return DatabaseService(tripDocID: tripDocID).removeVoteFromActivity(uid, fieldID);
                        }
                      }
                    ),
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
      ),
    );
  }
  favorite(String uid){
    if (activity.voters.contains(uid)){
      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }
}
