import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/trip_details/activity/add_new_activity.dart';
import 'package:travelcrew/screens/trip_details/explore/members/members_layout.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/size_config/size_config.dart';

import 'constants.dart';

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


  @override
  _TimePickersState createState() => _TimePickersState();
}

class _TimePickersState extends State<TimePickers> {

  String get _labelTextTimeStart {
    String _startTime = timeStart.format(context);
    startTime.value = _startTime;
    return _startTime;
  }
  String get _labelTextTimeEnd {
    String _endTime = timeEnd.format(context);
    endTime.value = _endTime;
    return endTime.value;
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
          padding: EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(_labelTextTimeStart,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
              ButtonTheme(
                minWidth: 150,
                child: RaisedButton(
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Start Time',
                  ),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(_labelTextTimeEnd,style: Theme.of(context).textTheme.subtitle1,),
//                                SizedBox(height: 16),
              ButtonTheme(
                minWidth: 150,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'End Time',
                  ),
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

class ProfileWidget extends StatelessWidget {
  final UserPublicProfile user;
  ProfileWidget({
    Key key,
    @required this.user,
  }) : super(key: key);

  final double defaultSize = SizeConfig.defaultSize;


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            ClipPath(
              clipper: CustomShape(),
              child: Container(
                height: defaultSize.toDouble() * 15.0, //150
                // color: Color(0xAA2D3D49),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (ThemeProvider.themeOf(context).id == 'light_theme') ? AssetImage(skyImage) : AssetImage(spaceImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: defaultSize), //10
              height: defaultSize * 30, //140
              width: defaultSize * 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: defaultSize * 0.5, //8
                ),
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: user.urlToImage.isNotEmpty ? NetworkImage(user.urlToImage,) : AssetImage(profileImagePlaceholder)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
            ),
            Center(
              child: Column(
                children: [
                  Text(user.displayName, textScaleFactor: 2.25,style: TextStyle(color: Colors.blueAccent,),),
                  Text('${user.firstName} ${user.lastName}', textScaleFactor: 1.9,style: TextStyle(color: Colors.blueAccent),),
                  if(user.uid == currentUserProfile.uid) Text(
                    '${user.email}',style: Theme.of(context).textTheme.subtitle1,),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Followers'),
                    Text('${user.followers.length}'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Following'),
                    Text('${user.following.length}'),
                  ],
                )
              ],
            )
          ],
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
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(10),
            height: SizeConfig.screenHeight*.7,
            child: MembersLayout(tripDetails: tripDetails,ownerID: userService.currentUserID,),
          ),
        );
      },
      child: const Text('Crew'),
    );
  }
}

class LinkPreview extends StatelessWidget {
  const LinkPreview({
    Key key,
    @required this.link,
  }) : super(key: key);

  final String link;

  @override
  Widget build(BuildContext context) {
    return FlutterLinkPreview(
      url: link,
      showMultimedia: true,
      bodyStyle: Theme.of(context).textTheme.subtitle1,
      builder: (info){
        if(info is WebInfo) {
          return Container(
              height: (info.image != null) ? 275 : 100,
              child: Column(
                children: [
                  (info.image != null) ?
                  Expanded(
                      flex: 2,
                      child: Image.network(
                        info.image,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                      )) : Container(),
                  if (info.description != null)
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(info.description, maxLines: 4,),
                      ),
                    ),
                ],
              )
          );
        }
        if (info is WebImageInfo) {
          return SizedBox(
            height: 350,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                info.image,
                fit: BoxFit.cover,
                width: double.maxFinite,
              ),
            ),
          );
        } else if (info is WebVideoInfo) {
          return SizedBox(
            height: 275,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                info.image,
                fit: BoxFit.cover,
                width: double.maxFinite,
              ),
            ),
          );
        } else{
          return Container();
        }
      },
    );
  }
}

// Widget DropDownTransportationList(BuildContext context) {
//   return
// }
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