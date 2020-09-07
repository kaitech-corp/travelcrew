import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/screens/menu_screens/users/users_search_page.dart';
import 'package:travelcrew/services/database.dart';

import 'layout_widgets.dart';
import 'lists/item_lists.dart';

class ExploreMemberLayout extends StatelessWidget{

  final Trip tripdetails;

  ExploreMemberLayout({this.tripdetails});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ImageLayout(tripdetails.urlToImage != "" ? tripdetails.urlToImage : "assets/images/travelPics.png"),
                ListTile(
                  title: Text('${tripdetails.location}'.toUpperCase(), style: TextStyle(fontSize: 20.0)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value){
                      switch (value) {
                        case "Members":
                          {
                            userAlertDialog(context);
                          }
                          break;
                        case "Add":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UsersSearchPage()),
                            );
                          }
                          break;
                        case "Leave":
                          {
                            _leaveTripAlert(context, user.uid);
                          }
                          break;
                        default:
                          {

                          }
                          break;
                      }
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) =>[
                      const PopupMenuItem(
                        value: 'Members',
                        child: ListTile(
                          leading: Icon(Icons.people),
                          title: Text('Crew'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Add',
                        child: ListTile(
                          leading: Icon(Icons.person_add),
                          title: Text('Add Member'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Leave',
                        child: ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text('Leave Group'),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Owner: ${tripdetails.displayName}', style: TextStyle(fontSize: 12.0),),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${tripdetails.travelType}'),
                        tripdetails.ispublic ? Text('Public') : Text('Private'),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Start: ${tripdetails.startDate}'),
                            Text('End: ${tripdetails.endDate}')
                          ],
                        )


                      ],
                    )
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                Container(
                  margin: const EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent)
                  ),
                  child: Text(tripdetails.comment, textScaleFactor: 1.25,),
                ),
                ListWidget(tripDetails: tripdetails,),
                BringListToDisplay(documentID: tripdetails.documentId,),
              ],
            ),
          ),
        )
    );
  }
  void _addAlertDialog(BuildContext context) {

    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Currently under development.'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {

                },
                child: Text('Thank you for you patience.'),
              ),
            ],
          );
        }
    );
  }

  Future<void> userAlertDialog(BuildContext context) async {

    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Members'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {

                },
                child: Text('${tripdetails.accessUsers.length} Member(s)'),
              ),
              SimpleDialogOption(
                onPressed: () {

                },
                child: Text(''),
              ),
            ],
          );
        }
    );
  }

  Future<void> _leaveTripAlert(BuildContext context, String uid) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Are you sure you want to leave this Trip?'),
          content: Text('You will no longer have access to this Trip'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                DatabaseService(tripDocID: tripdetails.documentId, uid: uid).leaveTrip();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      Wrapper(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


