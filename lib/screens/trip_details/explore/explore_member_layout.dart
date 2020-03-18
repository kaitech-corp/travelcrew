import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/services/database.dart';

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
                ImageLayout(tripdetails.urlToImage != "" ? tripdetails.urlToImage : "assests/images/travelPics.png"),
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
                            _addAlertDialog(context);
                          }
                          break;
                        case "Leave":
                          {
                            DatabaseService(tripDocID: tripdetails.documentId, uid: user.uid).leaveTrip();
                          }
                          break;
                        default:
                          {
                            print(value);
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
                  subtitle: Text('Owner', style: TextStyle(fontSize: 12.0),),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${tripdetails.travelType}'.toUpperCase()),
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
//              TextField(
//                cursorColor: Colors.grey,
//                decoration: InputDecoration(
//                    border: OutlineInputBorder(),
//                    hintText: 'A short desription of the trip will be shown here. This box will also be editable.'),
//                maxLines: 4,
//              ),
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
                  print('pressed');
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
                  print('pressed');
                },
                child: Text('${tripdetails.accessUsers.length} Member(s)'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  print('pressed');
                },
                child: Text(''),
              ),
            ],
          );
        }
    );
  }
}


