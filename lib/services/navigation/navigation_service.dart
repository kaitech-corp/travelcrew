import 'package:flutter/material.dart';

/// Handles the routes and the navigation in this app.
class NavigationService {
  GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  pop() {
    return _navigationKey.currentState.pop();
  }

  pushReplacementNamed(String routeName){
    return _navigationKey.currentState.pushReplacementNamed(routeName);
  }

  pushNamedAndRemoveUntil(String routeName){
    return _navigationKey.currentState.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return _navigationKey.currentState
        .pushNamed(routeName, arguments: arguments);
  }

}