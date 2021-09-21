import 'package:flutter/material.dart';
import 'package:travelcrew/services/widgets/badge_icon.dart';

class FavoriteWidget extends StatelessWidget {
  final List<String> voters;
  final String uid;

  const FavoriteWidget({Key key, this.voters, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (voters.length > 0)
        ? (voters.contains(uid))
            ? BadgeIcon(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                badgeCount: voters.length,
              )
            : BadgeIcon(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                ),
                badgeCount: voters.length,
              )
        : const Icon(Icons.favorite_border, color: Colors.red);
  }
}
