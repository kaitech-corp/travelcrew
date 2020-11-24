import 'package:flutter/material.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/screens/image_layout/image_layout_trips.dart';
import 'package:travelcrew/size_config/size_config.dart';


class TappableTripPreview extends StatelessWidget {

  final Trip trip;
  final heroTag;

  TappableTripPreview({this.trip, this.heroTag});

  var size = SizeConfig.screenHeight;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(trip.documentId),
      margin: const EdgeInsets.only(left: 20, bottom: 20, top: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        child: Container(
          height: trip.urlToImage.isNotEmpty ? size* .31 : size*.11,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              trip.urlToImage.isNotEmpty ? Flexible(flex: 3,child: Hero(tag: trip.urlToImage, transitionOnUserGestures: true,child: ImageLayout2(trip.urlToImage))) : Container(),
              Flexible(
                flex: 1,
                child: ListTile(
                  title: Text(trip.tripName ?? trip.location,style: Theme.of(context).textTheme.headline4,maxLines: 1,overflow: TextOverflow.ellipsis,),
                  subtitle:  Text(trip.startDate != null ? '${trip.startDate} - ${trip.endDate}' : 'Dates',style: Theme.of(context).textTheme.subtitle1,),
                  trailing: Tooltip(
                    message: 'Members',
                    child: Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 3,
                      children: <Widget>[
                        Text('${trip.accessUsers.length} ',style: Theme.of(context).textTheme.subtitle1,),
                        const Icon(Icons.people),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}