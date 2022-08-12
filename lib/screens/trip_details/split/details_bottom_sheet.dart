import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

import '../../../models/cost_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../services/constants/constants.dart';
import '../../../services/database.dart';
import '../../../size_config/size_config.dart';
import 'payment_details_menu_button.dart';

/// Bottom sheet for split cost details
class UserSplitCostDetailsBottomSheet extends StatelessWidget {
  const UserSplitCostDetailsBottomSheet({
    Key? key,
    required this.user,
    required this.costObject,
    this.splitObject,
    this.purchasedByUser,
  }) : super(key: key);

  final UserPublicProfile user;
  final CostObject costObject;
  final SplitObject splitObject;
  final UserPublicProfile purchasedByUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Colors.blue.shade50, Colors.lightBlueAccent.shade200]),
      ),
      padding: const EdgeInsets.all(10),
      height: SizeConfig.screenHeight * .5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: SizeConfig.screenWidth / 6,
            backgroundImage: user.urlToImage.isNotEmpty
                ? NetworkImage(
                    user.urlToImage,
                  )
                : AssetImage(profileImagePlaceholder),
          ),
          Text(user.displayName, style: Theme.of(context).textTheme.headline5),
          Container(
            height: 10,
          ),
          Text(
            'Payment details for:',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          Text(
            '"${splitObject.itemName}"',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
          ListTile(
            title: (costObject.paid == false)
                ? Text('Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.subtitle1)
                : Text('Paid', style: Theme.of(context).textTheme.subtitle1),
            subtitle: (userService.currentUserID == purchasedByUser.uid)
                ? Text('Paid to: You',
                    style: Theme.of(context).textTheme.subtitle2)
                : Text('Paid to: ${purchasedByUser.displayName}',
                    style: Theme.of(context).textTheme.subtitle2),
            trailing: (user.uid == userService.currentUserID ||
                    userService.currentUserID == purchasedByUser.uid)
                ? PaymentDetailsMenuButton(
                    costObject: costObject,
                    splitObject: splitObject,
                  )
                : null,
          ),
          (user.uid == userService.currentUserID ||
                  userService.currentUserID == purchasedByUser.uid)
              ? ElevatedButton(
                  onPressed: () {
                    DatabaseService().markAsPaid(costObject, splitObject);
                  },
                  child: const Text('Paid'),
                )
              : nil,
        ],
      ),
    );
  }
}
