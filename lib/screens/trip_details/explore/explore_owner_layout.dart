import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/authenticate/wrapper.dart';
import 'package:travelcrew/screens/menu_screens/users/users_search_page.dart';
import 'package:travelcrew/screens/trip_details/explore/edit_trip.dart';
import 'package:travelcrew/screens/trip_details/explore/layout_widgets.dart';
import 'package:travelcrew/screens/trip_details/explore/lists/item_lists.dart';
import 'package:travelcrew/screens/trip_details/explore/members/members_layout.dart';
import 'package:travelcrew/services/database.dart';



class ExploreLayout extends StatefulWidget {

  final Trip tripdetails;

  ExploreLayout({this.tripdetails});

  @override
  _ExploreLayoutState createState() => _ExploreLayoutState();
}

class _ExploreLayoutState extends State<ExploreLayout> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FadeInImage.assetNetwork(
                  placeholder: 'assets/images/travelPics.png',
                  image: widget.tripdetails.urlToImage,

                ),
                ListTile(
                  title: Text('${widget.tripdetails.location}'.toUpperCase(),
                      style: TextStyle(fontSize: 20.0)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case "Edit":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  EditTripData(tripdetails: widget.tripdetails,)),
                            );
                          }
                          break;
                        case "Members":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  MembersLayout(tripdetails: widget.tripdetails,)),
                            );
                          }
                          break;
                        case "Delete":
                          {
                            _deleteAlert(context);
                          }
                          break;
                        case "Add":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UsersSearchPage(tripDetails: widget.tripdetails,)),
                            );
                          }
                          break;
                        case "Convert":
                          {
                            _convertAlert(context, widget.tripdetails.ispublic);
                          }
                          break;
                        default:
                          {

                          }
                          break;
                      }
                    },
                    padding: EdgeInsets.zero,
                    itemBuilder: (context) =>
                    [
                      const PopupMenuItem(
                        value: 'Edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                        ),
                      ),
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
                      PopupMenuItem(
                        value: 'Convert',
                        child: ListTile(
                          leading: widget.tripdetails.ispublic ? Icon(Icons
                              .do_not_disturb_on) : Icon(Icons
                              .do_not_disturb_off),
                          title: widget.tripdetails.ispublic
                              ? Text('Make Private')
                              : Text('Make Public'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text('Delete Trip'),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Owner: ${widget.tripdetails.displayName}',
                    style: TextStyle(fontSize: 12.0),),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${widget.tripdetails.travelType}'),
                        widget.tripdetails.ispublic ? Text('Public') : Text('Private'),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Start: ${widget.tripdetails.startDate}'),
                            Text('End: ${widget.tripdetails.endDate}')
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
                  child: Text(widget.tripdetails.comment != null
                      ? widget.tripdetails.comment
                      : "No description provided", textScaleFactor: 1.25,),
                ),
                ListWidget(tripDetails: widget.tripdetails,),
                BringListToDisplay(documentID: widget.tripdetails.documentId,),

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
                child: Text('${widget.tripdetails.accessUsers.length} Member(s)'),
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

  Future<void> _deleteAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to delete this trip?'),
          content: const Text(
              'All data associated with this trip will be deleted.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                DatabaseService(tripDocID: widget.tripdetails.documentId)
                    .deleteTrip();
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

  Future<void> _convertAlert(BuildContext context, bool ispublic) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: ispublic
              ? Text(
              'Are you sure you want to convert this into a Private Trip?')
              : Text(
              'Are you sure you want to convert this into a Public Trip?'),
          content: ispublic
              ? Text('This trip will only be visible to members.')
              : Text('Trip will be become public for followers to see.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                DatabaseService().convertTrip(widget.tripdetails);
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


