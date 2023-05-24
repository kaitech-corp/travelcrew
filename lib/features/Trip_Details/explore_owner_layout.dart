import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';


import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/image_popup.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../services/widgets/reusable_widgets.dart';
import '../../../services/widgets/trip_details_widget.dart';
import '../../../size_config/size_config.dart';
import '../../models/trip_model/trip_model.dart';
import '../Alerts/alert_dialogs.dart';

import 'Image_animation.dart';
import 'members/members_layout.dart';

/// Layout for owner of trip.
class ExploreOwnerLayout extends StatefulWidget {
  const ExploreOwnerLayout({
    Key? key,
    required this.trip,
    required this.scaffoldKey,
  }) : super(key: key);

  final Trip trip;

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<ExploreOwnerLayout> createState() => _ExploreOwnerLayoutState();
}

class _ExploreOwnerLayoutState extends State<ExploreOwnerLayout> {
  final ExpandableController expandController = ExpandableController();

  bool didAnimate = true;
  double _padding = 10;
  double tabletSize = 15;
  double mobileSize = 10.0;

  @override
  void initState() {
    super.initState();
    expandController.addListener(onExpand);
  }

  void onExpand() {
    if (mounted) {
      setState(() {
        if (expandController.expanded) {
          _padding = SizeConfig.tablet ? tabletSize : mobileSize;
        } else {
          _padding = 10;
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
    final double detailsPadding = SizeConfig.screenWidth * .05;
    bool showImage = false;
    String image;

    final Event event = Event(
      title: widget.trip.tripName,
      description: widget.trip.comment,
      location: widget.trip.location,
      startDate: widget.trip.startDateTimeStamp!,
      endDate: widget.trip.endDateTimeStamp!,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          body: SingleChildScrollView(
        child: Stack(children: <Widget>[
          if (showImage)
            ImagePopup(
              imagePath: widget.trip.urlToImage,
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.trip.urlToImage.isNotEmpty)
                Column(
                  children: <Widget>[
                    GestureDetector(
                      onLongPress: () {
                        setState(() {
                          showImage = true;
                          image = widget.trip.urlToImage;
                        });
                      },
                      onLongPressEnd: (LongPressEndDetails details) {
                        setState(() {
                          showImage = false;
                        });
                      },
                      child: ImageAnimation(
                        trip: widget.trip,
                        expandController: expandController,
                      ),
                    ),
                    AnimatedPadding(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.only(top: _padding),
                        child: OwnerPopupMenuButton(
                          trip: widget.trip,
                          event: event,
                          scaffoldKey: widget.scaffoldKey,
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
                        child: OwnerPopupMenuButton(
                          trip: widget.trip,
                          event: event,
                          scaffoldKey: widget.scaffoldKey,
                        )),
                  ],
                ),
              Container(
                height: 1,
                color: ReusableThemeColor().colorOpposite(context),
              ),
              TripDetailsWidget(
                expandController: expandController,
                tripDetails: widget.trip,
                event: event,
                detailsPadding: detailsPadding,
              )
            ],
          ),
        ]),
      )),
    );
  }
}

class OwnerPopupMenuButton extends StatelessWidget {
  const OwnerPopupMenuButton({
    Key? key,
    required this.trip,
    required this.event,
    required this.scaffoldKey,
  }) : super(key: key);

  final Trip trip;
  final Event event;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            trip.tripName,
            style: SizeConfig.tablet
                ? headlineLarge(context)
                : headlineSmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            trip.displayName,
            style: titleMedium(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: PopupMenuButtonWidget(trip: trip, event: event),
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
                MapSearch().searchAddress(trip.location, context);
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
                        trip: trip,
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
    required this.trip,
    required this.event,
  }) : super(key: key);

  final Trip trip;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const IconThemeWidget(
        icon: Icons.more_horiz,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'Edit':
            {
              navigationService.navigateTo(EditTripDataRoute, arguments: trip);
            }
            break;
          case 'Calendar':
            {
              Add2Calendar.addEvent2Cal(event);
            }
            break;
          case 'Invite':
            {
              navigationService.navigateTo(FollowingListRoute, arguments: trip);
            }
            break;
          case 'Convert':
            {
              TravelCrewAlertDialogs().convertTripAlert(context, trip);
            }
            break;
          default:
            {
              TravelCrewAlertDialogs().deleteTripAlert(context, trip);
            }
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
        const PopupMenuItem<String>(
          value: 'Edit',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.edit),
            title: Text('Edit'),
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
        PopupMenuItem<String>(
          value: 'Convert',
          child: ListTile(
            leading: trip.ispublic
                ? const IconThemeWidget(icon: Icons.do_not_disturb_on)
                : const IconThemeWidget(icon: Icons.do_not_disturb_off),
            title: trip.ispublic
                ? const Text('Make Private')
                : const Text('Make Public'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.exit_to_app),
            title: Text('Delete Trip'),
          ),
        ),
      ],
    );
  }
}
