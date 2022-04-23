import 'package:flutter/material.dart';

import '../../../../models/trip_model.dart';
import '../../../../services/constants/constants.dart';
import '../controller/basket_controller.dart';
import 'cart_detailed_view_card.dart';

class CartDetailsView extends StatelessWidget {
  const CartDetailsView({Key key, this.controller, this.tripDetails})
      : super(key: key);

  final BasketController controller;
  final Trip tripDetails;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Recently Added:", style: Theme.of(context).textTheme.headline6),
          ...List.generate(
            controller.cart.length,
            (index) => CartDetailsViewCard(item: controller.cart[index]),
          ),
          SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}
