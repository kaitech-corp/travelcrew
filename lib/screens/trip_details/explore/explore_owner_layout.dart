import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/menu_screens/users/user_following_list_page.dart';
import 'package:travelcrew/screens/trip_details/explore/edit_trip.dart';
import 'package:travelcrew/screens/trip_details/explore/layout_widgets.dart';
import 'package:travelcrew/screens/trip_details/explore/lists/item_lists.dart';



class ExploreLayout extends StatefulWidget {

  final Trip tripDetails;

  ExploreLayout({this.tripDetails});

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
                  image: widget.tripDetails.urlToImage,

                ),
                ListTile(
                  title: Text('${widget.tripDetails.location}'.toUpperCase(),
                      style: TextStyle(fontSize: 20.0)),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case "Edit":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  EditTripData(tripDetails: widget.tripDetails,)),
                            );
                          }
                          break;
                        case "Delete":
                          {
                            TravelCrewAlertDialogs().deleteTripAlert(context, widget.tripDetails);
                          }
                          break;
                        case "Add":
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => currentUserFollowingList(tripDetails: widget.tripDetails,)),
                            );
                          }
                          break;
                        case "Convert":
                          {
                            TravelCrewAlertDialogs().convertTripAlert(context, widget.tripDetails);
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
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Add',
                        child: ListTile(
                          leading: const Icon(Icons.person_add),
                          title: const Text('Add Member'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Convert',
                        child: ListTile(
                          leading: widget.tripDetails.ispublic ? const Icon(Icons
                              .do_not_disturb_on) : const Icon(Icons
                              .do_not_disturb_off),
                          title: widget.tripDetails.ispublic
                              ? const Text('Make Private')
                              : const Text('Make Public'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: ListTile(
                          leading: const Icon(Icons.exit_to_app),
                          title: const Text('Delete Trip'),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('Owner: ${widget.tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle2,),
                ),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Trip: ${widget.tripDetails.travelType}',style: Theme.of(context).textTheme.subtitle1,),
                        widget.tripDetails.ispublic ? Text('Public',style: Theme.of(context).textTheme.subtitle1,) : Text('Private',style: Theme.of(context).textTheme.subtitle1,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Start: ${widget.tripDetails.startDate}',style: Theme.of(context).textTheme.subtitle1,),
                            Text('End: ${widget.tripDetails.endDate}',style: Theme.of(context).textTheme.subtitle1,)
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
                  child: Text(widget.tripDetails.comment != null
                      ? widget.tripDetails.comment
                      : "No description provided",style: Theme.of(context).textTheme.subtitle1,),
                ),
                ListWidget(tripDetails: widget.tripDetails,),
                const Padding(padding: EdgeInsets.only(top: 5),),
                Container(height: 1,color: Colors.grey,),
                BringListToDisplay(documentID: widget.tripDetails.documentId,),

              ],
            ),
          ),
        )
    );
  }


}


