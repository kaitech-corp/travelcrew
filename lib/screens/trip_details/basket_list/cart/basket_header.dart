

import 'package:flutter/material.dart';
import 'package:travelcrew/screens/trip_details/basket_list/controller/basket_controller.dart';
import 'package:travelcrew/services/constants/constants.dart';
import 'package:travelcrew/services/widgets/appearance_widgets.dart';

class BasketHeader extends StatelessWidget {

  final BasketController controller;

  const BasketHeader({
    Key key, this.controller
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: basketHeaderHeight,
      color: canvasColor,
      padding: const EdgeInsets.all(defaultPadding),
      child: AnimatedSwitcher(
        duration: listAnimationDuration,
        child:  Column(
          children: [
            if (controller.homeState == BasketState.normal) Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add to List",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        // .copyWith(color: Colors.black54),
                  ),
                  IconButton(onPressed: (){
                    if(controller.homeState == BasketState.normal){
                      controller.changeBasketState(BasketState.add);
                    }else if(controller.homeState == BasketState.add) {
                      controller.changeBasketState(BasketState.normal);
                    }
                      },
                      icon: IconThemeWidget(icon: Icons.add,))
                  // CircleAvatar(
                  //   backgroundColor: Colors.transparent,
                  //   backgroundImage: AssetImage(profileImagePlaceholder),
                  // )
                ],
              ),
            ),
            if (controller.homeState == BasketState.add) Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      "Full List",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                    // .copyWith(color: Colors.black54),
                  ),
                  IconButton(onPressed: (){
                    if(controller.homeState == BasketState.normal){
                      controller.changeBasketState(BasketState.add);
                    }else if(controller.homeState == BasketState.add) {
                      controller.changeBasketState(BasketState.normal);
                    }
                  },
                      icon: IconThemeWidget(icon: Icons.list,))
                  // CircleAvatar(
                  //   backgroundColor: Colors.transparent,
                  //   backgroundImage: AssetImage(profileImagePlaceholder),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}