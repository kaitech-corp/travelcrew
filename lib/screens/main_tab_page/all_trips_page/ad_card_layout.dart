import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/reusableWidgets.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'package:travelcrew/size_config/size_config.dart';
import '../../../loading.dart';
import 'all_trips_new_design.dart';




class AdTileCard extends StatefulWidget {


  @override
  _AdTileCardState createState() => _AdTileCardState();
}

class _AdTileCardState extends State<AdTileCard> {

  double _width = 200;
  double _margins = 5;
  var _radius = Radius.zero;
  // var _borderRadius = BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20));
  var _borderRadius = BorderRadius.circular(20);


  void animate(){
    if(animatePress){
      setState(() {
        _width = SizeConfig.screenWidth*.6;
        _borderRadius = BorderRadius.circular(60);
        // _borderRadius = BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60));
        _margins = 30;
        _radius = Radius.circular(60);
      });
    } else {
      setState(() {
        _width = 200;
        _borderRadius = BorderRadius.circular(20);
        // _borderRadius = BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20));
        _margins = 5;
        _radius = Radius.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    animate();
    return StreamBuilder(
        stream: DatabaseService().adList,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final adList = snapshot.data;
                  TripAds ad = adList[index];
                  // TripAds ad = snapshot.data[index];
                  return AnimatedAd(margins: _margins, width: _width, borderRadius: _borderRadius, radius: _radius, ad: ad);
                }
            );
          } else {
            return Loading();
          }
        }
    );
  }
}

class AnimatedAd extends StatelessWidget {
  const AnimatedAd({
    Key key,
    @required double margins,
    @required double width,
    @required BorderRadius borderRadius,
    @required Radius radius,
    @required this.ad,
  }) : _margins = margins, _width = width, _borderRadius = borderRadius, _radius = radius, super(key: key);


  final double _margins;
  final double _width;
  final BorderRadius _borderRadius;
  final Radius _radius;
  final TripAds ad;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.linear,
      duration: Duration(seconds: 1),
      margin: EdgeInsets.all(_margins),
      // height: _height,
      width: _width,
      decoration: BoxDecoration(
        color: (ThemeProvider.themeOf(context).id == 'light_theme') ? Colors.white : Colors.black12,
        borderRadius: _borderRadius,
      ),
      child: GestureDetector(
        onTap: (){
          TCFunctions().launchURL(ad.link);
          CloudFunction().updateClicks(ad.documentID);
        },
        child: Column(
          children: [
            animatePress ?
            Expanded(
              flex: 3,
              child: AnimatedClipRRect(
                duration: Duration(seconds: 1),
                curve: Curves.linear,
                borderRadius: BorderRadius.only(topLeft: _radius,topRight: _radius),
                  child: Image.network(ad.urlToImage,fit: BoxFit.fill,)),
            )
                : Container(),
            Expanded(
              flex: 2,
              child: ListTile(
                title: Text(
                  ad.tripName,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                ),
                subtitle: Text(
                  ad.location,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
