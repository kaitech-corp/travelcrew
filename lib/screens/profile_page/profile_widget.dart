import 'package:flutter/material.dart';

import '../../models/custom_objects.dart';
import '../../services/constants/constants.dart';
import '../../services/theme/text_styles.dart';
import '../../services/widgets/appearance_widgets.dart';
import '../../services/widgets/reusable_widgets.dart';
import '../../size_config/size_config.dart';

class ProfileWidget extends StatelessWidget {
  ProfileWidget({
    Key? key,
    required this.user,
  }) : super(key: key);
  final UserPublicProfile user;
  final double profileSize = SizeConfig.screenWidth * .45;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 6,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(10.0, sizeFromHangingTheme, 10.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Hero(
                      tag: user.uid,
                      transitionOnUserGestures: true,
                      child: SizedBox(
                        height: profileSize,
                        width: profileSize,
                        child: CircleAvatar(
                          radius: SizeConfig.screenWidth / 1.8,
                          backgroundImage: NetworkImage(
                              user.urlToImage ?? profileImagePlaceholder),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(
                          right: 8.0, left: 8.0, top: sizeFromHangingTheme / 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: SizeConfig.screenHeight * .1,
                          ),
                          Row(
                            children: <Widget>[
                              const IconThemeWidget(
                                icon: Icons.person,
                              ),
                              Flexible(
                                  child: Text(
                                user.displayName,
                                style: titleMedium(context),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const IconThemeWidget(
                                icon: Icons.location_pin,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (user.hometown?.isNotEmpty ?? false)
                                      Text(
                                        user.hometown!,
                                        style: titleMedium(context),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      )
                                    else
                                      Text('Hometown',
                                          style: titleSmall(context)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Card(
                margin: EdgeInsets.fromLTRB(SizeConfig.screenWidth / 7.0, 0,
                    SizeConfig.screenWidth / 7.0, 0),
                color: ReusableThemeColor().cardColor(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: SizeConfig.screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                            child: Text(
                          'Destination Wish List',
                          style: titleMedium(context),
                          textScaleFactor: 1.1,
                        )),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                if (user.topDestinations != null &&
                                    user.topDestinations.isNotEmpty)
                                for (int i = 0;
                                    i < (user.topDestinations.length ?? 0);
                                    i++)
                                  // if (user.topDestinations?[i].isNotEmpty ?? false)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${user.topDestinations?[i]}',style: titleMedium(context),),
                                    ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))),
          ),
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 58.0),
            child: Text(
              'Recent Trips',
              style: titleMedium(context),
            ),
          ),
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                  height: 150,
                  child: RecentTripTile(
                    uid: user.uid,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}