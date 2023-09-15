import 'package:flutter/material.dart';
import 'badge_icon.dart';

class FavoriteWidget extends StatelessWidget {

  const FavoriteWidget({super.key, required this.voters, required this.uid});
  final List<dynamic> voters;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return (voters.isNotEmpty)
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
