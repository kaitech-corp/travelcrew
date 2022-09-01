import 'package:flutter/material.dart';

Widget BasketIcon(String? department) {

    switch (department){
      case 'Food':
        return const CircleAvatar(child: Icon(Icons.fastfood));
      case 'Toys':
        return const CircleAvatar(child: Icon(Icons.games));
      case 'Home':
        return const CircleAvatar(child: Icon(Icons.shopping_cart));
      default:
        return const CircleAvatar(child: Icon(Icons.shopping_basket));
    }

}