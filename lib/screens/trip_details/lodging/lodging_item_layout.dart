import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/trip_details/activity/web_view_screen.dart';
import 'package:travelcrew/services/database.dart';

class LodgingItemLayout extends StatelessWidget {

  final LodgingData lodging;
  final String tripDocID;
  LodgingItemLayout({this.lodging, this.tripDocID});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

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
//                      ListTile(
//                        title: Text('Lodging Type'),
//                        subtitle: Text('Description'),
//                      ),
                      Text('${lodging.lodgingType}'),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                      ),


                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${lodging.displayName}'),
                        Text('Likes: ${lodging.vote}'),
                      ],
                    ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      Text('Comment: ${lodging.comment}'),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                      ),
                      Column (
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (lodging.link != "") Text('Link attached'),
                          if (lodging.urlToImage != '') ImageLayout(lodging.urlToImage),
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
                          String fieldID = lodging.fieldID;
                          String uid = user.uid;
                          if (!lodging.voters.contains(user.uid)) {
                            return DatabaseService(tripDocID: tripDocID).addVoteToLodging(uid, fieldID);
                          } else {
                            return DatabaseService(tripDocID: tripDocID).removeVoteFromLodging(uid, fieldID);
                          }
                        }
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value){
                        switch (value){
                          case "Edit": {

                          }
                          break;
                          case "View": {
//                            if (activity.link.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  WebViewScreen(lodging.link, key)),
                            );
//                            }
                          }
                          break;
                          default: {
                            print(value);
                          }
                          break;
                        }
                      },
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) =>[
                        const PopupMenuItem(
                          value: 'Edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'View',
                          child: ListTile(
                            leading: Icon(Icons.people),
                            title: Text('View Link'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: ListTile(
                            leading: Icon(Icons.exit_to_app),
                            title: Text('Delete Lodging'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
  favorite(String uid){
    if (lodging?.voters?.contains(uid)){
      return Icon(Icons.favorite);
    } else {
      return Icon(Icons.favorite_border);
    }
  }
}
