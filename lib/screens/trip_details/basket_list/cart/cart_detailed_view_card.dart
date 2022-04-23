import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';
import '../../../../services/constants/constants.dart';
import '../../../../services/widgets/basket_icon.dart';



class CartDetailsViewCard extends StatelessWidget {
  const CartDetailsViewCard({
    Key key,
    this.item,
  }) : super(key: key);

  final WalmartProductsItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      leading: BasketIcon(item.walmartProducts.type),
      title: Text(
        item.walmartProducts.query,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .copyWith(fontWeight: FontWeight.bold),
      ),
      trailing: FittedBox(
        child: Row(
          children: [
            // Price(amount: "20"),
            Text(
              "  x ${item.quantity}",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}