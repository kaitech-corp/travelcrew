import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../../../models/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/navigation/route_names.dart';
import '../../../services/navigation/router.dart';
import '../../../services/widgets/appearance_widgets.dart';
import '../../../services/widgets/image_popup.dart';
import '../../../services/widgets/reusableWidgets.dart';
import '../../../services/widgets/trip_details_widget.dart';
import '../../../size_config/size_config.dart';
import '../../alerts/alert_dialogs.dart';
import '../basket_list/controller/basket_controller.dart';
import 'ImageAnimation.dart';
import 'members/members_layout.dart';


class ExploreOwnerLayout extends StatefulWidget {

  final Trip tripDetails;
  final heroTag;

  final GlobalKey<ScaffoldState> scaffoldKey;
  final PersistentBottomSheetController controller;


  ExploreOwnerLayout({this.tripDetails, this.heroTag, this.scaffoldKey, this.controller,});

  @override
  _ExploreOwnerLayoutState createState() => _ExploreOwnerLayoutState();
}

class _ExploreOwnerLayoutState extends State<ExploreOwnerLayout> {

  final expandController = ExpandableController();
  final basketController = BasketController();

  bool didAnimate = true;
  double _padding = SizeConfig.screenHeight*.35;
  double tabletSize = SizeConfig.defaultSize.toDouble() * 13.0;
  double mobileSize = SizeConfig.defaultSize.toDouble() * 10.0;

  @override
  void initState() {
    super.initState();
    expandController.addListener(onExpand);
  }

  onExpand(){
    if(mounted){
      setState(() {
        if (expandController.expanded) {
          _padding = SizeConfig.tablet ? tabletSize : mobileSize;
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
  }



  @override
  Widget build(BuildContext context) {

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
                            expandController: expandController,),
                        ),
                        AnimatedPadding(
                            duration: Duration(milliseconds: 250),
                            padding: EdgeInsets.only(top: _padding),
                            child: OwnerPopupMenuButton(tripDetails: widget.tripDetails, event: event,controller: widget.controller,scaffoldKey: widget.scaffoldKey,basketController: basketController,)),
                      ],
                    ):
                    Stack(
                      children: [
                        HangingImageTheme(),
                        Padding(
                            padding: EdgeInsets.only(top: SizeConfig.screenHeight*.16),
                            child: OwnerPopupMenuButton(tripDetails: widget.tripDetails, event: event,controller: widget.controller,scaffoldKey: widget.scaffoldKey,basketController: basketController,)),
                      ],
                    ),
                    Container(height: 1,color: ReusableThemeColor().colorOpposite(context),),
                    TripDetailsWidget(
                      expandController: expandController,
                      tripDetails: widget.tripDetails,
                      event: event,
                      detailsPadding: _detailsPadding,
                    )
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
    @required this.event, this.scaffoldKey, this.controller,this.basketController

  }) : super(key: key);

  final Trip tripDetails;
  final Event event;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final PersistentBottomSheetController controller;
  final BasketController basketController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('${tripDetails.tripName}',
            style: SizeConfig.tablet ? Theme.of(context).textTheme.headline4 : Theme.of(context).textTheme.headline6,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${tripDetails.displayName}',style: Theme.of(context).textTheme.subtitle1,maxLines: 1,overflow: TextOverflow.ellipsis,),
          trailing: PopupMenuButtonWidget(tripDetails: tripDetails, event: event),
        ),
        Container(height: 1,color: ReusableThemeColor().colorOpposite(context),),
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: (){
              MapsLauncher.launchQuery(tripDetails.location);
              },
            icon: TripDetailsIconThemeWidget(icon: Icons.map,),),
          IconButton(
            onPressed: (){
              navigationService.navigateTo(BasketListPageRoute, arguments: BasketListArguments(tripDetails: tripDetails,basketController: basketController));

            },
            icon: TripDetailsIconThemeWidget(icon: Icons.shopping_basket,),),
          IconButton(
            onPressed: (){
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(10),
                  height: SizeConfig.screenHeight*.7,
                  child: MembersLayout(tripDetails: tripDetails,ownerID: userService.currentUserID,),
                ),
              );},
            icon: TripDetailsIconThemeWidget(icon: Icons.people,)),

        ],
        )
      ],
    );
  }
}

class PopupMenuButtonWidget extends StatelessWidget {
  const PopupMenuButtonWidget({
    Key key,
    @required this.tripDetails,
    @required this.event,
  }) : super(key: key);

  final Trip tripDetails;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: IconThemeWidget(icon: Icons.more_horiz,),
      onSelected: (value) {
        switch (value) {
          case "Edit":
            {
              navigationService.navigateTo(EditTripDataRoute, arguments: tripDetails);
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
              TravelCrewAlertDialogs().deleteTripAlert(context, tripDetails);
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
    );
  }
}



