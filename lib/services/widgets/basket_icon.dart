import 'package:flutter/material.dart';

Widget BasketIcon(String? department) {

    switch (department){
      case 'Food':
        return CircleAvatar(child: Icon(Icons.fastfood));
      case 'Toys':
        return CircleAvatar(child: Icon(Icons.games));
      case 'Home':
        return CircleAvatar(child: Icon(Icons.shopping_cart));
      default:
        return CircleAvatar(child: Icon(Icons.shopping_basket));
    }

}