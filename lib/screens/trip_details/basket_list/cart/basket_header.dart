import 'package:flutter/material.dart';

import '../../../../services/constants/constants.dart';
import '../../../../services/widgets/appearance_widgets.dart';
import '../controller/basket_controller.dart';

class BasketHeader extends StatelessWidget {
  final BasketController controller;

  const BasketHeader({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: basketHeaderHeight,
      color: canvasColor,
      padding: const EdgeInsets.all(defaultPadding),
      child: AnimatedSwitcher(
        duration: listAnimationDuration,
        child: Column(
          children: [
            if (controller.homeState == BasketState.normal)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add to List",
                        style: Theme.of(context).textTheme.headline6
                        // .copyWith(color: Colors.black54),
                        ),
                    IconButton(
                        onPressed: () {
                          if (controller.homeState == BasketState.normal) {
                            controller.changeBasketState(BasketState.add);
                          } else if (controller.homeState == BasketState.add) {
                            controller.changeBasketState(BasketState.normal);
                          }
                        },
                        icon: IconThemeWidget(
                          icon: Icons.add,
                        ))
                  ],
                ),
              ),
            if (controller.homeState == BasketState.add)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Full List",
                        style: Theme.of(context).textTheme.headline6
                        // .copyWith(color: Colors.black54),
                        ),
                    IconButton(
                        onPressed: () {
                          if (controller.homeState == BasketState.normal) {
                            controller.changeBasketState(BasketState.add);
                          } else if (controller.homeState == BasketState.add) {
                            controller.changeBasketState(BasketState.normal);
                          }
                        },
                        icon: IconThemeWidget(
                          icon: Icons.list,
                        ))
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
