import 'package:flutter/material.dart';

import '../../../models/trip_model.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import '../../image_layout/image_layout_trips.dart';

/// Tappable trip preview
class TappableTripPreview extends StatelessWidget {
  const TappableTripPreview({
    Key? key,
    required this.trip,
  }) : super(key: key);

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final double size = SizeConfig.screenHeight;
    return Card(
      key: Key(trip.documentId),
      margin: const EdgeInsets.only(left: 20, bottom: 20, top: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        child: SizedBox(
          height: (trip.urlToImage.isNotEmpty) ? size * .31 : size * .11,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (trip.urlToImage.isNotEmpty)
                Flexible(
                    flex: 3,
                    child: Hero(
                        tag: trip.urlToImage,
                        transitionOnUserGestures: true,
                        child: ImageLayout(trip.urlToImage)))
              else
                Container(),
              Flexible(
                child: ListTile(
                  title: Text(
                    trip.tripName,
                    style: headlineLarge(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    trip.startDate != null
                        ? '${trip.startDate} - ${trip.endDate}'
                        : 'Dates',
                    style: titleMedium(context),
                  ),
                  trailing: Tooltip(
                    message: 'Members',
                    child: Wrap(
                      spacing: 3,
                      children: <Widget>[
                        Text(
                          '${trip.accessUsers.length} ',
                          style: titleMedium(context),
                        ),
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
