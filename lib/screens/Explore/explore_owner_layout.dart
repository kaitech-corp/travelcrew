import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/map_launcher.dart';
import '../../../services/widgets/reusable_widgets.dart';
import '../../../size_config/size_config.dart';
import '../../models/trip_model/trip_model.dart';
import 'components/Image_animation.dart';
import 'components/card_details_widget.dart';
import 'components/owner_menu.dart';
import 'logic/logic.dart';
import 'members/members_layout.dart';

/// Layout for owner of trip.
class ExploreOwnerLayout extends StatefulWidget {
  const ExploreOwnerLayout({
    super.key,
    required this.trip,
    required this.scaffoldKey,
  });

  final Trip trip;

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<ExploreOwnerLayout> createState() => _ExploreOwnerLayoutState();
}

class _ExploreOwnerLayoutState extends State<ExploreOwnerLayout> {
  final ExpandableController expandController = ExpandableController();
  final ScrollController scrollController = ScrollController();

  bool didAnimate = true;
  double _padding = 10;
  double tabletSize = 15;
  double mobileSize = 10.0;

  @override
  void initState() {
    super.initState();
    expandController.addListener(onExpand);
    scrollController.addListener(onScroll);
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

  void onScroll() {
    if (scrollController.offset != scrollController.position.minScrollExtent) {
      expandController.expanded = true;
    } else {
      expandController.expanded = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    expandController.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final double detailsPadding = SizeConfig.screenWidth * .05;

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
                controller: scrollController,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  if (widget.trip.urlToImage?.isNotEmpty ?? false)
                    Column(
                      children: <Widget>[
                        ImageAnimation(
                          trip: widget.trip,
                          expandController: expandController,
                        ),
                        AnimatedPadding(
                            duration: const Duration(milliseconds: 350),
                            padding: EdgeInsets.only(top: _padding),
                            child: OwnerMenuBar(
                              trip: widget.trip,
                              event: event,
                              scaffoldKey: widget.scaffoldKey,
                            )),
                      ],
                    )
                  else
                    Column(
                      children: <Widget>[
                        const HangingImageTheme(),
                        Padding(
                            padding: EdgeInsets.only(
                                top: SizeConfig.screenHeight * .16),
                            child: OwnerMenuBar(
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
                  DetailsCardOne(trip: widget.trip),
                  DetailsCardTwo(trip: widget.trip, event: event),
                  SizedBox(
                    height: SizeConfig.screenWidth * .1,
                  )
                ]))));
  }
}

class OwnerMenuBar extends StatelessWidget {
  const OwnerMenuBar({
    super.key,
    required this.trip,
    required this.event,
    required this.scaffoldKey,
  });

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
                : titleMedium(context)?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            trip.displayName ?? '',
            style: titleMedium(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: PopupOwnerMenuButtonWidget(trip: trip, event: event),
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
                MapSearch().searchAddress(trip.location ?? '', context);
              },
              icon: const TripDetailsIconThemeWidget(
                icon: Icons.map,
              ),
            ),
            IconButton(
              onPressed: () {
                Add2Calendar.addEvent2Cal(event);
              },
              icon: const TripDetailsIconThemeWidget(
                icon: Icons.calendar_month,
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
            IconButton(
                onPressed: () {
                  shareTrip(context, trip.ispublic, trip.documentId);
                },
                icon: const TripDetailsIconThemeWidget(
                  icon: Icons.share,
                ))
          ],
        )
      ],
    );
  }
}
