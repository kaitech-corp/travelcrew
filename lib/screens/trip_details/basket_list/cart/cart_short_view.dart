import 'package:flutter/material.dart';
import 'package:travelcrew/screens/trip_details/basket_list/controller/basket_controller.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/widgets/basket_icon.dart';


class CartShortView extends StatelessWidget {
  const CartShortView({
    Key key,
    this.controller,
  }) : super(key: key);

  final BasketController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Recent:",
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(width: defaultPadding),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                controller.cart.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(right: defaultPadding / 2),
                  child: Hero(
                    tag: controller.cart[index].walmartProducts.query + "_cartTag",
                    child: BasketIcon(controller.cart[index].walmartProducts.type),
                  ),
                ),
              ),
            ),
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Text(
            controller.totalCartItems().toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        )
      ],
    );
  }
}