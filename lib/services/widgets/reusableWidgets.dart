import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../models/custom_objects.dart';
import '../../models/trip_model.dart';
import '../../screens/trip_details/explore/members/members_layout.dart';
import '../../services/database.dart';
import '../../services/functions/tc_functions.dart';
import '../../services/locator.dart';
import '../../services/navigation/route_names.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../size_config/size_config.dart';
import '../constants/constants.dart';
import 'loading.dart';

final double defaultSize = SizeConfig.defaultSize;

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double height = size.height;
    final double width = size.width;
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
    final Path path = Path();
    final double height = size.height;
    final double width = size.width;
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

  const ImageBanner(this._assetPath, {Key? key}) : super(key: key);
  final String _assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height * .33,
        ),
        decoration: const BoxDecoration(color: Colors.grey),
        child: Image.asset(_assetPath,
          fit: BoxFit.fill,
        ));
  }
}



class AnimatedClipRRect extends StatelessWidget {
  const AnimatedClipRRect({
    required this.duration,
    this.curve = Curves.linear,
    required this.borderRadius,
    required this.child,
  })  : assert(duration != null),
        assert(curve != null),
        assert(borderRadius != null),
        assert(child != null);

  final Duration duration;
  final Curve curve;
  final BorderRadius borderRadius;
  final Widget child;

  static Widget _builder(
      BuildContext context, BorderRadius radius, Widget? child) {
    return ClipRRect(borderRadius: radius, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<BorderRadius>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: BorderRadius.zero, end: borderRadius),
      builder: _builder,
      child: child,
    );
  }
}


class HangingImageTheme extends StatelessWidget {
  const HangingImageTheme({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
        height: SizeConfig.screenHeight*.22, //150
        // color:
        decoration: const BoxDecoration(
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

  HangingImageTheme3({
    Key? key, required this.user,
  }) : super(key: key);

  final UserPublicProfile currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();
  final double hgt = SizeConfig.screenHeight*.06;
  final UserPublicProfile user;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CustomShape(),
      child: Container(
          height: SizeConfig.screenHeight*.22, //150
          // color:
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(skyImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
              child:
              Stack(
                children: [
                  Positioned.fill(
                    child: AppBar(
                      shadowColor: const Color(0x00000000),
                      backgroundColor: const Color(0x00000000),
                      actions: <Widget>[
                        if (currentUserProfile.uid == user.uid) IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: (){
                            navigationService.navigateTo(EditProfilePageRoute);
                            // Navigator.pushNamed(context, '/cropperTest');
                          },
                        ) else Container(),
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
    Key? key,
    required this.urlToImage
  }) : super(key: key);

  final String urlToImage;

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
    Key? key,
    required this.tripDetails,
  }) : super(key: key);

  final Trip tripDetails;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
          ),
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10),
            height: SizeConfig.screenHeight*.7,
            child: MembersLayout(trip: tripDetails,ownerID: userService.currentUserID,),
          ),
        );
      },
      child: Text('Crew ${tripDetails.accessUsers!.length} '),
    );
  }
}

class DateGauge extends StatelessWidget {
  const DateGauge({
    Key? key,
    required this.tripDetails,
  }) : super(key: key);

  final Trip tripDetails;


  @override
  Widget build(BuildContext context) {


    final CountDownDate countDownDate = TCFunctions().dateGauge(
        tripDetails.dateCreatedTimeStamp!.millisecondsSinceEpoch,
        tripDetails.startDateTimeStamp!.millisecondsSinceEpoch);
    final CountDownDate countDownDateReturn = TCFunctions().dateGauge(
        tripDetails.startDateTimeStamp!.millisecondsSinceEpoch,
        tripDetails.endDateTimeStamp!.millisecondsSinceEpoch);
    final String result = TCFunctions().checkDate(tripDetails.startDateTimeStamp!.millisecondsSinceEpoch, tripDetails.endDateTimeStamp!.millisecondsSinceEpoch);

    switch (result){
      case 'before':
        return Gauge(countDownDate: countDownDate, color: ReusableThemeColor().bottomNavColor(context),);
      case 'during':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Trip has started.'),
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
    Key? key,
    required this.countDownDate,required this.color
  }) : super(key: key);

  final CountDownDate countDownDate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight*.2,
      width: SizeConfig.screenWidth*.5,
      child: SfRadialGauge(
        animationDuration: 1250,
          enableLoadingAnimation: true,
          axes: <RadialAxis>[
            RadialAxis(
                maximum: countDownDate.initialDayCount!,
                showLabels: false,
                showTicks: false,
                startAngle: 180,
                endAngle: 0,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.2,
                  cornerStyle: CornerStyle.bothCurve,
                  color: Color.fromARGB(30, 0, 169, 181),
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: countDownDate.gaugeCount!,
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
                        '${countDownDate.daysLeft!.toStringAsFixed(0)} Days Left',
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

  const RecentTripTile({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot<Object?> streamData){
          if(streamData.hasData){
            final List<Trip> trips = streamData.data as List<Trip>;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (trips.length > 10) ? 10 : trips.length,
              itemBuilder: (BuildContext context, int index){
                final Trip trip = trips[index];
                return InkWell(
                  onTap: (){
                    navigationService.navigateTo(ExploreBasicRoute,arguments: trip);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: (trip.urlToImage?.isNotEmpty?? false) ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          trip.urlToImage!,
                          fit: BoxFit.cover,
                          height: 125,
                          width: 125,
                        )):
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: const LinearGradient(
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