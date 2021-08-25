import 'package:flutter/material.dart';

Widget BasketIcon(String department) {

    switch (department){
      case 'Food':
        return CircleAvatar(child: Icon(Icons.fastfood));
      break;
      case 'Toys':
        return CircleAvatar(child: Icon(Icons.games));
      break;
      case 'Home':
        return CircleAvatar(child: Icon(Icons.shopping_cart));
      break;
      default:
        return CircleAvatar(child: Icon(Icons.shopping_basket));
    }

}