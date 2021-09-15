import 'package:flutter/material.dart';
import 'package:travelcrew/models/trip_model.dart';
import 'package:travelcrew/screens/trip_details/basket_list/controller/basket_controller.dart';
import 'package:travelcrew/services/constants/constants.dart';

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
