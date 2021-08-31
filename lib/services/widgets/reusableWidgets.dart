import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/explore/members/members_layout.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/tc_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/navigation/route_names.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';
import 'package:travelcrew/size_config/size_config.dart';

import '../constants/constants.dart';
import 'loading.dart';

final double defaultSize = SizeConfig.defaultSize;

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double height = size.height;
    double width = size.width;
    path.lineTo(0, height - 100);
    path.quadraticBezierTo(width / 2, height, width, height - 100);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CustomShape2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double height = size.height;
    double width = size.width;
    path.lineTo(0, height - 0);
    path.quadraticBezierTo(width / 1, height, width, height - 0);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ImageBanner extends StatelessWidget{
  final String _assetPath;

  ImageBanner(this._assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height * .33,
        ),
        decoration: BoxDecoration(color: Colors.grey),
        child: Image.asset(_assetPath,
          fit: BoxFit.fill,
        ));
  }
}

class TimePickers extends StatefulWidget{

  final bool lodging;
  final ValueNotifier<String> startTime;
  final ValueNotifier<String> endTime;

  const TimePickers({Key key, this.lodging, this.startTime, this.endTime}) : super(key: key);


  @override
  _TimePickersState createState() => _TimePickersState();

}

class _TimePickersState extends State<TimePickers> {
  TimeOfDay timeStart;
  TimeOfDay timeEnd;

  @override
  void initState() {
    timeStart = widget.lodging ? TimeOfDay.fromDateTime(DateTime.utc(2021,1,1,15,0)): TimeOfDay.fromDateTime(DateTime.utc(2021,1,1,9,0));
    timeEnd = widget.lodging ? TimeOfDay.fromDateTime(DateTime.utc(2021,1,1,11,0)): TimeOfDay.fromDateTime(DateTime.utc(2021,1,1,15,0));
    super.initState();
  }



  String get _labelTextTimeStart {
    String _startTime = timeStart.format(context);
    widget.startTime.value = _startTime;
    return _startTime;
  }
  String get _labelTextTimeEnd {
    String _endTime = timeEnd.format(context);
    widget.endTime.value = _endTime;
    return _endTime;
  }

  Future<void> showTimePickerStart(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: timeStart,
    );
    if (picked != null && picked != timeStart) {
      setState(() {
        timeStart = picked;
      });
    }
  }
  Future<void> showTimePickerEnd(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: timeEnd,
    );
    if (picked != null && picked != timeEnd) {
      setState(() {
        timeEnd = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    TripDetailsIconThemeWidget(icon: Icons.access_time,),
                    SizedBox(width: 8,),
                    Text(_labelTextTimeStart,style: Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
//                                SizedBox(height: 16),
              ButtonTheme(
                minWidth: 150,
                child: ElevatedButton(
                  child:widget.lodging ? Text('Check In') :Text('Start Time',),
                  onPressed: () async {
                    showTimePickerStart(context);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    TripDetailsIconThemeWidget(icon: Icons.access_time,),
                    SizedBox(width: 8,),
                    Text(_labelTextTimeEnd,style: Theme.of(context).textTheme.subtitle1,),
                  ],
                ),
              ),
//                                SizedBox(height: 16),
              ButtonTheme(
                minWidth: 150,
                child: ElevatedButton(
                  child: widget.lodging ? Text('Checkout') :Text('End Time',),
                  onPressed: () {
                    showTimePickerEnd(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedClipRRect extends StatelessWidget {
  const AnimatedClipRRect({
    @required this.duration,
    this.curve = Curves.linear,
    @required this.borderRadius,
    @required this.child,
  })  : assert(duration != null),
        assert(curve != null),
        assert(borderRadius != null),
        assert(child != null);

  final Duration duration;
  final Curve curve;
  final BorderRadius borderRadius;
  final Widget child;

  static Widget _builder(
      BuildContext context, BorderRadius radius, Widget child) {
    return ClipRRect(borderRadius: radius, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<BorderRadius>(
      duration: duration,
      curve: curve,
      tween: BorderRadiusTween(begin: BorderRadius.zero, end: borderRadius),
      builder: _builder,
      child: child,
    );
  }
}


class HangingImageTheme extends StatelessWidget {
  const HangingImageTheme({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
        height: SizeConfig.screenHeight*.22, //150
        // color:
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(skyImage),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class HangingImageTheme3 extends StatelessWidget {

  final currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final double hgt = SizeConfig.screenHeight*.06;
  final UserPublicProfile user;

  HangingImageTheme3({
    Key key, this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
          height: SizeConfig.screenHeight*.22, //150
          // color:
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(skyImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
              padding: EdgeInsets.fromLTRB(8.0,0,8.0,0),
              child:
              Stack(
                children: [
                  Positioned.fill(
                    child: AppBar(
                      shadowColor: Color(0x00000000),
                      backgroundColor: Color(0x00000000),
                      actions: <Widget>[
                        (currentUserProfile.uid == user.uid) ? IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: (){
                            navigationService.navigateTo(EditProfilePageRoute);
                            // Navigator.pushNamed(context, '/cropperTest');
                          },
                        ) :
                        Container(),
                      ],
                    ),
                  ),
                ],
              )

            //   ],
            // ),
          ),
      ),
    );
  }
}

class CustomHangingImage extends StatelessWidget {
  const CustomHangingImage({
    Key key,
    this.urlToImage
  }) : super(key: key);

  final urlToImage;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
        height: 350, //150
        // color: Color(0xAA2D3D49),
        decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(urlToImage),
                fit: BoxFit.cover)
        ),
      ),
    );
  }
}

class CrewModalBottomSheet extends StatelessWidget {
  const CrewModalBottomSheet({
    Key key,
    @required this.tripDetails,
  }) : super(key: key);

  final Trip tripDetails;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
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
        );
      },
      child: Text("Crew ${tripDetails.accessUsers.length} "),
    );
  }
}

class DateGauge extends StatelessWidget {
  const DateGauge({
    Key key,
    @required this.tripDetails,
  }) : super(key: key);

  final Trip tripDetails;


  @override
  Widget build(BuildContext context) {


    CountDownDate countDownDate = TCFunctions().dateGauge(
        tripDetails.dateCreatedTimeStamp.millisecondsSinceEpoch,
        tripDetails.startDateTimeStamp.millisecondsSinceEpoch);
    CountDownDate countDownDateReturn = TCFunctions().dateGauge(
        tripDetails.startDateTimeStamp.millisecondsSinceEpoch,
        tripDetails.endDateTimeStamp.millisecondsSinceEpoch);
    String result = TCFunctions().checkDate(tripDetails.startDateTimeStamp.millisecondsSinceEpoch, tripDetails.endDateTimeStamp.millisecondsSinceEpoch);

    switch (result){
      case 'before':
        return Gauge(countDownDate: countDownDate, color: ReusableThemeColor().bottomNavColor(context),);
      case 'during':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Trip has started.'),
            Gauge(countDownDate: countDownDateReturn, color: Colors.blue,),
          ],
        );
        default:
        return Gauge(countDownDate: CountDownDate(daysLeft: 0,initialDayCount: 1,gaugeCount: 1),color: Colors.blue,);
    }
  }
}

class Gauge extends StatelessWidget {
  const Gauge({
    Key key,
    @required this.countDownDate,@required this.color
  }) : super(key: key);

  final CountDownDate countDownDate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.screenHeight*.2,
      width: SizeConfig.screenWidth*.5,
      child: SfRadialGauge(
        animationDuration: 1250,
          enableLoadingAnimation: true,
          axes: <RadialAxis>[
            RadialAxis(
                minimum: 0.0,
                maximum: countDownDate.initialDayCount,
                showLabels: false,
                showTicks: false,
                startAngle: 180,
                endAngle: 0,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.2,
                  cornerStyle: CornerStyle.bothCurve,
                  color: Color.fromARGB(30, 0, 169, 181),
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: countDownDate.gaugeCount,
                    cornerStyle: CornerStyle.bothCurve,
                    width: 0.2,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: color,
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      positionFactor: 0.1,
                      angle: 90,
                      widget: Text(
                        countDownDate.daysLeft.toStringAsFixed(0) + ' Days Left',
                        style: Theme.of(context).textTheme.subtitle1,
                      ))
                ])
          ]
      ),
    );
  }
}



//Recent Trip tile
class RecentTripTile extends StatelessWidget{
  final String uid;

  const RecentTripTile({Key key, this.uid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        builder: (context, streamData){
          if(streamData.hasData){
            List<Trip> trips = streamData.data;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (trips.length > 10) ? 10 : trips.length,
              itemBuilder: (context, index){
                Trip trip = trips[index];
                return InkWell(
                  onTap: (){
                    navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: (trip.urlToImage.isNotEmpty) ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          trip.urlToImage,
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        )):
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue,
                              Colors.lightBlueAccent
                            ]
                        ),
                      ),
                      height: 125,
                      width: 125,
                      child: ListTile(
                        title: Text('${trip.tripName}',style: Theme
                            .of(context)
                            .textTheme
                            .subtitle1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,),
                        subtitle: Text('${trip.location}',style: Theme
                            .of(context)
                            .textTheme
                            .subtitle2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,),
                      ),
                    ),
                  ),
                );
              });
          } else {
            return Loading();
          }
        },
        stream: DatabaseService().pastCrewTripsCustom(uid),
    );
  }

}

//
// Widget PlacesNearbyList(String place, Position currentPosition) {
//   return FutureBuilder(
//     builder: (context, places) {
//       if(places.hasData) {
//         return ListView.builder(
//             itemCount: places.data.length,
//             itemBuilder: (context, index) {
//               TrueWay place = places.data[index];
//               return Card(
//                 child: InkWell(
//                   key: Key(place.name),
//                   splashColor: Colors.blueAccent,
//                   onTap: () {
//                     TCFunctions().launchURL(place.website);
//                   },
//                   child: ListTile(
//                     title: Text('${place.name}',
//                       style: TextStyle(fontSize: 24, color: Colors.black),),
//                     subtitle: Text('Address: ${place.address}',
//                       style: TextStyle(fontSize: 12, color: Colors.black),),
//                     trailing: IconButton(
//                       icon: Icon(Icons.post_add),
//                       onPressed: (){
//                         Navigator.push(context, MaterialPageRoute(builder: (context) => AddTrip(addedLocation: place.address,)),);
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             }
//         );
//       } else {
//         return Loading();
//       }
//     },
//     future:  PlacesNearby().getNearbyPlaces(place,
//         currentPosition?.latitude.toString() ?? '',
//         currentPosition?.longitude.toString()) ?? '',
//   );
// }