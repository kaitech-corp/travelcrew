import 'package:flutter/material.dart';

import '../../../models/cost_model.dart';
import '../../../models/split_model.dart';
import '../../../services/database.dart';
import '../../../services/widgets/appearance_widgets.dart';

/// Payment details menu button
class PaymentDetailsMenuButton extends StatelessWidget {
  const PaymentDetailsMenuButton({
    Key? key,
    required this.costObject,
    this.splitObject,

  }) : super(key: key);

  final CostObject costObject;
  final SplitObject splitObject;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: IconThemeWidget(icon: Icons.edit,),
      onSelected: (value) {
        switch (value) {
          case "Edit":
            {

            }
            break;
          case "Delete":
            {
              DatabaseService().deleteCostObject(costObject, splitObject);
              navigationService.pop();
            }
            break;
          default:
            {

            }
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) =>
      [
        // const PopupMenuItem(
        //   value: 'Edit',
        //   child: ListTile(
        //     leading: IconThemeWidget(icon: Icons.edit),
        //     title: const Text('Edit'),
        //   ),
        // ),
        const PopupMenuItem(
          value: 'Delete',
          child: ListTile(
            leading: IconThemeWidget(icon: Icons.delete),
            title: const Text('Remove'),
          ),
        ),
      ],
    );
  }
}
