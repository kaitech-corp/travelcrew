import 'package:flutter/material.dart';

import '../../../../models/trip_model.dart';
import '../../../../services/constants/constants.dart';
import '../controller/basket_controller.dart';
import 'cart_detailed_view_card.dart';

class CartDetailsView extends StatelessWidget {
  const CartDetailsView({Key? key, required this.controller, required this.trip})
      : super(key: key);

  final BasketController controller;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Recently Added:', style: Theme.of(context).textTheme.headline6),
          ...List<Widget>.generate(
            controller.cart.length,
            (int index) => CartDetailsViewCard(item: controller.cart[index]),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}
