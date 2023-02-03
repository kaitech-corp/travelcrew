import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../services/widgets/reusableWidgets.dart';
import '../../../services/widgets/trip_details_widget.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';
import '../basket_list/controller/basket_controller.dart';
import 'ImageAnimation.dart';
import 'members/members_layout.dart';

/// Layout for members of trip.
class ExploreMemberLayout extends StatefulWidget {
  const ExploreMemberLayout({
    Key? key,
    required this.tripDetails,
    required this.scaffoldKey,
  }) : super(key: key);

  final Trip tripDetails;

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<ExploreMemberLayout> createState() => _ExploreMemberLayoutState();
}

class _ExploreMemberLayoutState extends State<ExploreMemberLayout> {
  final ExpandableController expandController = ExpandableController();
  final BasketController basketController = BasketController();

  bool didAnimate = true;
  double _padding = SizeConfig.screenHeight * .35;

  @override
  void initState() {
    super.initState();
    expandController.addListener(onExpand);
  }

  void onExpand() {
    if (mounted) {
      setState(() {
        if (expandController.expanded) {
          _padding = SizeConfig.defaultSize * 10.0;
        } else {
          _padding = SizeConfig.screenHeight * .35;
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    expandController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // double _height = 3.0;
    final double detailsPadding = SizeConfig.screenWidth * .05;

    final Event event = Event(
      title: widget.tripDetails.tripName,
      description: widget.tripDetails.comment,
      location: widget.tripDetails.location,
      startDate: widget.tripDetails.startDateTimeStamp.toDate(),
      endDate: widget.tripDetails.endDateTimeStamp.toDate(),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(children: <Widget>[
          if (widget.tripDetails.urlToImage.isNotEmpty)
            Stack(
              children: <Widget>[
                ImageAnimation(
                  trip: widget.tripDetails,
                  expandController: expandController,
                ),
                AnimatedPadding(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.only(top: _padding),
                    child: MemberPopupMenuButton(
                      tripDetails: widget.tripDetails,
                      event: event,
                      scaffoldKey: widget.scaffoldKey,
                      basketController: basketController,
                    )),
              ],
            )
          else
            Stack(
              children: <Widget>[
                const HangingImageTheme(),
                Padding(
                    padding:
                        EdgeInsets.only(top: SizeConfig.screenHeight * .16),
                    child: MemberPopupMenuButton(
                      tripDetails: widget.tripDetails,
                      event: event,
                      scaffoldKey: widget.scaffoldKey,
                      basketController: basketController,
                    )),
              ],
            ),
          Container(
            height: 1,
            color: ReusableThemeColor().colorOpposite(context),
          ),
          TripDetailsWidget(
            expandController: expandController,
            tripDetails: widget.tripDetails,
            event: event,
            detailsPadding: detailsPadding,
          )
        ]),
      )),
    );
  }
}

class MemberPopupMenuButton extends StatelessWidget {
  const MemberPopupMenuButton({
    Key? key,
    required this.tripDetails,
    required this.event,
    required this.scaffoldKey,
    this.basketController,
  }) : super(key: key);

  final Trip tripDetails;
  final Event event;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final BasketController? basketController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            tripDetails.tripName,
            style: SizeConfig.tablet
                ? Theme.of(context).textTheme.headline4
                : Theme.of(context).textTheme.headline6,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing:
              PopupMenuButtonWidget(tripDetails: tripDetails, event: event),
        ),
        Container(
          height: 1,
          color: ReusableThemeColor().colorOpposite(context),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: () {
                MapSearch().searchAddress(tripDetails.location, context);
              },
              icon: const TripDetailsIconThemeWidget(
                icon: Icons.map,
              ),
            ),
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    builder: (BuildContext context) => Container(
                      padding: const EdgeInsets.all(10),
                      height: SizeConfig.screenHeight * .7,
                      child: MembersLayout(
                        trip: tripDetails,
                        ownerID: userService.currentUserID,
                      ),
                    ),
                  );
                },
                icon: const TripDetailsIconThemeWidget(
                  icon: Icons.people,
                )),
          ],
        )
      ],
    );
  }
}

class PopupMenuButtonWidget extends StatelessWidget {
  const PopupMenuButtonWidget({
    Key? key,
    required this.tripDetails,
    required this.event,
  }) : super(key: key);

  final Trip tripDetails;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const IconThemeWidget(
        icon: Icons.more_horiz,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'Report':
            {
              TravelCrewAlertDialogs().reportAlert(
                  context: context,
                  tripDetails: tripDetails,
                  type: 'tripDetails');
            }
            break;
          case 'Calendar':
            {
              Add2Calendar.addEvent2Cal(event);
            }
            break;
          case 'Invite':
            {
              navigationService.navigateTo(FollowingListRoute,
                  arguments: tripDetails);
            }
            break;
          case 'Leave':
            {
              TravelCrewAlertDialogs().leaveTripAlert(
                  context, userService.currentUserID, tripDetails);
            }
            break;
          default:
            {}
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          value: 'Report',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.report),
            title: Text('Report'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Calendar',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.calendar_today_outlined),
            title: Text('Save to Calendar'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Invite',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.person_add),
            title: Text('Invite'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Leave',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.exit_to_app),
            title: Text('Leave Group'),
          ),
        ),
      ],
    );
  }
}
