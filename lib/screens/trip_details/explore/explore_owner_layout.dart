import 'package:add_2_calendar/add_2_calendar.dart';
export 'package:add_2_calendar/src/add_2_cal.dart';
export 'package:add_2_calendar/src/model/event.dart';
import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/explore/followers/user_following_list_page.dart';
import 'package:travelcrew/screens/add_trip/edit_trip.dart';
import 'package:travelcrew/screens/trip_details/explore/layout_widgets.dart';
import 'package:travelcrew/screens/trip_details/explore/lists/item_lists.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/reusableWidgets.dart';




class ExploreLayout extends StatefulWidget {

  final Trip tripDetails;
  final heroTag;

  ExploreLayout({this.tripDetails, this.heroTag});

  @override
  _ExploreLayoutState createState() => _ExploreLayoutState();
}

class _ExploreLayoutState extends State<ExploreLayout> {


  @override
  Widget build(BuildContext context) {

    final Event event = Event(
      title: widget.tripDetails.tripName,
      description: widget.tripDetails.comment,
      location: widget.tripDetails.location,
      startDate: widget.tripDetails.startDateTimeStamp.toDate(),
      endDate: widget.tripDetails.endDateTimeStamp.toDate(),
    );

    return Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Hero(
                  tag: widget.tripDetails.urlToImage,
                  transitionOnUserGestures: true,
                  child: FadeInImage.assetNetwork(
                    placeholder: travelImage,
                    image: widget.tripDetails.urlToImage,

                  ),
                ),
                OwnerPopupMenuButton(widget: widget, event: event,),
                Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Type: ${widget.tripDetails.travelType}',style: Theme.of(context).textTheme.subtitle1,),
                            widget.tripDetails.ispublic ? Text('Public',style: Theme.of(context).textTheme.subtitle1,) : Text('Private',style: Theme.of(context).textTheme.subtitle1,),
                          ],
                        ),
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
                Container(
                  margin: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListWidget(tripDetails: widget.tripDetails,),
                      CrewModalBottomSheet(tripDetails: widget.tripDetails),
                    ],
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 5),),
                Container(height: 1,color: Colors.grey,),
                BringListToDisplay(tripDocID: widget.tripDetails.documentId,),

              ],
            ),
          ),
        )
    );
  }


}

class OwnerPopupMenuButton extends StatelessWidget {
  const OwnerPopupMenuButton({
    Key key,
    @required this.widget,
    @required this.event,

  }) : super(key: key);

  final ExploreLayout widget;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
            case "Calendar":
              {
                Add2Calendar.addEvent2Cal(event);
              }
              break;
            case "Invite":
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
            value: 'Calendar',
            child: ListTile(
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Save to Calendar'),
            ),
          ),
          const PopupMenuItem(
            value: 'Invite',
            child: ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite'),
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
    );
  }
}




