import 'package:flutter/material.dart';

import '../../../../models/custom_objects.dart';

enum BasketState { normal, cart, add }

class BasketController extends ChangeNotifier {
  BasketState homeState = BasketState.normal;

  List<WalmartProductsItem> cart = <WalmartProductsItem>[];

  void changeBasketState(BasketState state) {
    homeState = state;
    notifyListeners();
  }

  void addWalmartProductsToCart(WalmartProducts walmartProducts) {
    for (final WalmartProductsItem item in cart) {
      if (item.walmartProducts!.query == walmartProducts.query) {
        item.increment();
        notifyListeners();
        return;
      }
    }
    cart.add(WalmartProductsItem(walmartProducts: walmartProducts));
    notifyListeners();
  }

  int totalCartItems() => cart.fold(
      0, (int previousValue, WalmartProductsItem element) => previousValue + element.quantity);
}
