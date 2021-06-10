// import 'package:add_2_calendar/add_2_calendar.dart';
// import 'package:expandable/expandable.dart';
// export 'package:add_2_calendar/src/add_2_cal.dart';
// export 'package:add_2_calendar/src/model/event.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/screens/trip_details/cost/cost_split_page.dart';
import 'package:travelcrew/screens/trip_details/cost/split_package.dart';
import 'package:travelcrew/screens/trip_details/explore/layout_widgets.dart';
import 'package:travelcrew/screens/trip_details/explore/lists/item_lists.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/navigation/navigation_service.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/services/widgets/image_popup.dart';
import 'package:travelcrew/services/widgets/reusableWidgets.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';
import 'package:clipboard/clipboard.dart';
import 'ImageAnimation.dart';


// enum Response{}

class ExploreOwnerLayout extends StatefulWidget {

  final Trip tripDetails;
  final heroTag;

  final GlobalKey<ScaffoldState> scaffoldKey;
  PersistentBottomSheetController controller;

  ExploreOwnerLayout({this.tripDetails, this.heroTag, this.scaffoldKey, this.controller});

  @override
  _ExploreOwnerLayoutState createState() => _ExploreOwnerLayoutState();
}

class _ExploreOwnerLayoutState extends State<ExploreOwnerLayout> {

  final expandController = ExpandableController();
  final expandController2 = ExpandableController();
  final expandController3 = ExpandableController();

  bool didAnimate = true;
  double _padding = SizeConfig.screenHeight*.35;
  double _tripDetailsBoxSize = SizeConfig.screenHeight*.18;
  double _tripDetailsCardEdgeInset = 8.0;
  @override
  void initState() {
    super.initState();
    // controller.addListener(onScroll);
    expandController.addListener(onExpand);
    expandController2.addListener(onExpand);
    expandController3.addListener(onExpand);
  }

  onExpand(){
    if(mounted){
      setState(() {
        if (expandController.expanded ||
            expandController2.expanded ||
            expandController3.expanded) {
          _padding = SizeConfig.defaultSize.toDouble() * 10.0;
        } else {
          _padding = SizeConfig.screenHeight*.35;
        }
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    expandController.dispose();
    expandController2.dispose();
    expandController3.dispose();
  }



  @override
  Widget build(BuildContext context) {

    // double _height = 3.0;
    double _detailsPadding = SizeConfig.screenWidth*.05;
    var _showImage = false;
    String _image;

    final Event event = Event(
      title: widget.tripDetails.tripName,
      description: widget.tripDetails.comment,
      location: widget.tripDetails.location,
      startDate: widget.tripDetails.startDateTimeStamp.toDate(),
      endDate: widget.tripDetails.endDateTimeStamp.toDate(),
    );



    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          body: Container(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  if(_showImage) ImagePopup(imagePath: widget.tripDetails.urlToImage,),
                  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    (widget.tripDetails.urlToImage.isNotEmpty) ? Stack(
                      children: [
                        GestureDetector(
                          onLongPress: (){
                            setState(() {
                              _showImage = true;
                              _image = widget.tripDetails.urlToImage;
                            });
                          },
                          onLongPressEnd: (details) {
                            setState(() {
                              _showImage = false;
                            });
                          },
                          child: ImageAnimation(tripDetails: widget.tripDetails,
                            expandController: expandController,
                            expandController2: expandController2,
                            expandController3: expandController3,),
                        ),
                        AnimatedPadding(
                            duration: Duration(milliseconds: 250),
                            padding: EdgeInsets.only(top: _padding),
                            child: OwnerPopupMenuButton(tripDetails: widget.tripDetails, event: event,)),
                      ],
                    ):
                    Stack(
                      children: [
                        HangingImageTheme(),
                        Padding(
                            padding: EdgeInsets.only(top: SizeConfig.screenHeight*.16),
                            child: OwnerPopupMenuButton(tripDetails: widget.tripDetails, event: event,)),
                      ],
                    ),
                    Container(height: 1,color: ReusableThemeColor().colorOpposite(context),),
                    SizedBox(height: 15,),
                    Stack(
                      children: [
                        DateGauge(tripDetails: widget.tripDetails),
                        Positioned(
                          bottom: 10,
                          left: 18.0,
                          right: 18.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ListWidget(tripDetails: widget.tripDetails,controller: widget.controller,scaffoldKey: widget.scaffoldKey,),
                              ElevatedButton(
                                onPressed: (){
                                  navigationService.navigateTo(CostPageRoute,arguments: widget.tripDetails);
                            },
                                child: Text("Split",),
                                // Text('Crew ${tripDetails.accessUsers.length} ${Icons.people}'),
                              ),
                              CrewModalBottomSheet(tripDetails: widget.tripDetails),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ExpandableNotifier(
                        controller: expandController,
                        child: ScrollOnExpand(
                          scrollOnExpand: true,
                          child: ExpandableTheme(
                            data: ExpandableThemeData(
                              iconSize: 25.0,
                              iconColor: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.white,
                            ),
                            child: ExpandablePanel(
                              header: Text('Trip Details', style: Theme.of(context).textTheme.headline2,),
                              // collapsed:
                              expanded: Padding(
                                padding: EdgeInsets.all(_detailsPadding),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            FlutterClipboard.copy(widget.tripDetails.location).whenComplete(() => TravelCrewAlertDialogs().copiedToClipboardDialog(context));
                                          },
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
                                            child: Container(
                                              padding: EdgeInsets.all(_tripDetailsCardEdgeInset),
                                              height: _tripDetailsBoxSize,
                                              width: _tripDetailsBoxSize,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  TripDetailsIconThemeWidget(icon: Icons.location_pin,),
                                                  Text('${widget.tripDetails.location}',style: Theme.of(context).textTheme.subtitle1,maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
                                          child: InkWell(
                                            onTap: (){
                                              Add2Calendar.addEvent2Cal(event);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(_tripDetailsCardEdgeInset),
                                              height: _tripDetailsBoxSize,
                                              width: _tripDetailsBoxSize,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  TripDetailsIconThemeWidget(icon: Icons.calendar_today,),
                                                  Text('${TCFunctions().dateToMonthDay(widget.tripDetails.startDate)} - ${widget.tripDetails.endDate}',style: Theme.of(context).textTheme.subtitle1, textAlign: TextAlign.center,),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
                                          child: Container(
                                            padding: EdgeInsets.all(_tripDetailsCardEdgeInset),
                                            height: _tripDetailsBoxSize,
                                            width: _tripDetailsBoxSize,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TripDetailsIconThemeWidget(icon: Icons.label,),
                                                Text('${widget.tripDetails.travelType}',style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
                                          child: InkWell(
                                            onTap: (){
                                              TravelCrewAlertDialogs().convertTripAlert(context, widget.tripDetails);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(_tripDetailsCardEdgeInset),
                                              height: _tripDetailsBoxSize,
                                              width: _tripDetailsBoxSize,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  widget.tripDetails.ispublic ? TripDetailsIconThemeWidget(icon: Icons.public,) : TripDetailsIconThemeWidget(icon: Icons.public_off,),
                                                  widget.tripDetails.ispublic ? Text('Public',style: Theme.of(context).textTheme.subtitle1,) : Text('Private',style: Theme.of(context).textTheme.subtitle1,),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if(widget.tripDetails.comment.isNotEmpty) Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
                                      child: InkWell(
                                        onTap: (){

                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(_tripDetailsCardEdgeInset),
                                          // height: _tripDetailsBoxSize,
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TripDetailsIconThemeWidget(icon: Icons.comment,),
                                              Text(widget.tripDetails.comment,style: Theme.of(context).textTheme.subtitle1,textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,8.0),
                      child: ExpandableNotifier(
                        controller: expandController2,
                        child: ScrollOnExpand(
                          scrollOnExpand: true,
                          child: ExpandableTheme(
                            data: ExpandableThemeData(
                              iconSize: 25.0,
                              iconColor: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.white,
                            ),
                            child: ExpandablePanel(
                              header: Text('Bringing', style: Theme.of(context).textTheme.headline2,),
                              // collapsed:
                              expanded: BringListToDisplay(tripDocID: widget.tripDetails.documentId,),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,25),
                      child: ExpandableNotifier(
                        controller: expandController3,
                        child: ScrollOnExpand(
                          scrollOnExpand: true,
                          child: ExpandableTheme(
                            data: ExpandableThemeData(
                              iconSize: 25.0,
                              iconColor: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.black : Colors.white,
                            ),
                            child: ExpandablePanel(
                              header: Text('Need', style: Theme.of(context).textTheme.headline2,),
                              // collapsed:
                              expanded: NeedListToDisplay(documentID: widget.tripDetails.documentId,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),]
              ),
            ),
          )
      ),
    );
  }
}



class OwnerPopupMenuButton extends StatelessWidget {
  const OwnerPopupMenuButton({
    Key key,
    @required this.tripDetails,
    @required this.event,

  }) : super(key: key);

  final Trip tripDetails;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${tripDetails.tripName}'.toUpperCase(),
        style: TextStyle(fontSize: 20.0),maxLines: 2,overflow: TextOverflow.ellipsis,),
      subtitle: Text('${tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle1,maxLines: 1,overflow: TextOverflow.ellipsis,),
      trailing: PopupMenuButton<String>(
        icon: IconThemeWidget(icon: Icons.more_horiz,),
        onSelected: (value) {
          switch (value) {
            case "Edit":
              {
                navigationService.navigateTo(EditTripDataRoute, arguments: tripDetails);
              }
              break;
            case "Delete":
              {
                TravelCrewAlertDialogs().deleteTripAlert(context, tripDetails);
              }
              break;
            case "Calendar":
              {
                Add2Calendar.addEvent2Cal(event);
              }
              break;
            case "Invite":
              {
                navigationService.navigateTo(FollowingListRoute, arguments: tripDetails);
              }
              break;
            case "Convert":
              {
                TravelCrewAlertDialogs().convertTripAlert(context, tripDetails);
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
              leading: IconThemeWidget(icon: Icons.edit),
              title: const Text('Edit'),
            ),
          ),
          const PopupMenuItem(
            value: 'Calendar',
            child: ListTile(
              leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
              title: const Text('Save to Calendar'),
            ),
          ),
          const PopupMenuItem(
            value: 'Invite',
            child: ListTile(
              leading: IconThemeWidget(icon: Icons.person_add),
              title: const Text('Invite'),
            ),
          ),
          PopupMenuItem(
            value: 'Convert',
            child: ListTile(
              leading: tripDetails.ispublic ? IconThemeWidget(icon: Icons
                  .do_not_disturb_on) : IconThemeWidget(icon: Icons
                  .do_not_disturb_off),
              title: tripDetails.ispublic
                  ? const Text('Make Private')
                  : const Text('Make Public'),
            ),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: ListTile(
              leading: IconThemeWidget(icon: Icons.exit_to_app),
              title: const Text('Delete Trip'),
            ),
          ),
        ],
      ),
    );
  }
}



