import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

import '../../../models/cost_model.dart';
import '../../../models/custom_objects.dart';
import '../../../models/split_model.dart';
import '../../../services/database.dart';
import '../../../services/theme/text_styles.dart';
import '../../../size_config/size_config.dart';
import 'components/payment_details_menu_button.dart';

/// Bottom sheet for split cost details
class UserSplitCostDetailsBottomSheet extends StatelessWidget {
  const UserSplitCostDetailsBottomSheet({
    Key? key,
    required this.user,
    required this.costObject,
    required this.splitObject,
    required this.purchasedByUser,
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
            colors: <Color>[Colors.blue.shade50, Colors.lightBlueAccent.shade200]),
      ),
      padding: const EdgeInsets.all(10),
      height: SizeConfig.screenHeight * .5,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: SizeConfig.screenWidth / 6,
            backgroundImage: NetworkImage(user.urlToImage),
          ),
          Text(user.displayName, style: headlineMedium(context)),
          Container(
            height: 10,
          ),
          Text(
            'Payment details for:',
            style: headlineSmall(context),
            textAlign: TextAlign.center,
          ),
          Text(
            '"${splitObject.itemName}"',
            style: headlineSmall(context),
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
          ListTile(
            title: (costObject.paid == false)
                ? Text('Owe: \$${costObject.amountOwe.toStringAsFixed(2)}',
                    style: titleMedium(context))
                : Text('Paid', style: titleMedium(context)),
            subtitle: (userService.currentUserID == purchasedByUser.uid)
                ? Text('Paid to: You',
                    style: titleSmall(context))
                : Text('Paid to: ${purchasedByUser.displayName}',
                    style: titleSmall(context)),
            trailing: (user.uid == userService.currentUserID ||
                    userService.currentUserID == purchasedByUser.uid)
                ? PaymentDetailsMenuButton(
                    costObject: costObject,
                    splitObject: splitObject,
                  )
                : null,
          ),
          if (user.uid == userService.currentUserID ||
                  userService.currentUserID == purchasedByUser.uid) ElevatedButton(
                  onPressed: () {
                    DatabaseService().markAsPaid(costObject, splitObject);
                  },
                  child: const Text('Paid'),
                ) else nil,
        ],
      ),
    );
  }
}
