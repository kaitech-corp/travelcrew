import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';

enum BasketState { normal, cart, add }

class BasketController extends ChangeNotifier {
  BasketState homeState = BasketState.normal;

  List<WalmartProductsItem> cart = [];

  void changeBasketState(BasketState state) {
    homeState = state;
    notifyListeners();
  }

  void addWalmartProductsToCart(WalmartProducts walmartProducts) {
    for (WalmartProductsItem item in cart) {
      if (item.walmartProducts.query == walmartProducts.query) {
        item.increment();
        notifyListeners();
        return;
      }
    }
    cart.add(WalmartProductsItem(walmartProducts: walmartProducts));
    notifyListeners();
  }

  int totalCartItems() => cart.fold(
      0, (previousValue, element) => previousValue + element.quantity);
}

