import 'package:flutter/material.dart';

import '../../../../services/theme/text_styles.dart';
import '../../../../size_config/size_config.dart';
import '../../../models/cost_model/cost_object_model.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../Profile/logic/logic.dart';
import '../logic/split_functions.dart';

class PrepaidDetailsCard extends StatelessWidget {
  const PrepaidDetailsCard({
    super.key,
    required this.items,
    required this.uid,
  });

  final List<CostObjectModel> items;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final UserPurchase userDetails = calculateTotalForUser(uid, items);
    if (userDetails.total <= 0) {
      return const SizedBox.shrink(); // Returns an empty widget
    }
    return Card(
      child: FutureBuilder<UserPublicProfile>(
        builder:
            (BuildContext context, AsyncSnapshot<UserPublicProfile> userData) {
          if (userData.hasData) {
            final UserPublicProfile user = userData.data!;
            return Container(
              padding: EdgeInsets.all(SizeConfig.defaultPadding),
              height: SizeConfig.screenWidth * .35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${user.displayName} Owes: ',
                    maxLines: 2,
                    style: SizeConfig.tablet
                        ? headlineMedium(context)
                        : titleMedium(context),
                  ),
                  Text(
                    '\$${userDetails.total.toStringAsFixed(2)}',
                    style: SizeConfig.tablet
                        ? headlineMedium(context)
                        : titleMedium(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.all(SizeConfig.defaultPadding),
              height: SizeConfig.screenWidth * .35,
              width: SizeConfig.screenWidth * .4,
              child: const Column(
                children: <Widget>[
                  Text('Name: N/A'),
                  Text(r'Paid: $0.00'),
                ],
              ),
            );
          }
        },
        future: specificUserPublicProfile(userDetails.userId!),
      ),
    );
  }
}
