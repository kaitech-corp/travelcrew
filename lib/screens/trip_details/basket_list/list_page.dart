import 'package:flutter/material.dart';
import '../../../models/trip_model.dart';
import 'cart/basket_header.dart';
import '../explore/lists/addToListPage.dart';
import '../explore/lists/item_lists.dart';
import '../../../services/constants/constants.dart';
import '../../../size_config/size_config.dart';

import 'cart/cart_detailed_view.dart';
import 'cart/cart_short_view.dart';
import 'controller/basket_controller.dart';

class BasketListPage extends StatelessWidget{

  final Trip tripDetails;
  final BasketController controller;

  BasketListPage({Key key, this.tripDetails,this.controller}) : super(key: key);




  static bool pressed = false;

  void _onVerticalGesture(DragUpdateDetails details) {
    if (details.primaryDelta < -0.7) {
      controller.changeBasketState(BasketState.cart);
    } else if (details.primaryDelta > 12) {
      controller.changeBasketState(BasketState.normal);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Explore',style: Theme.of(context).textTheme.headline5,),),
      backgroundColor: canvasColor,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: canvasColor,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _){
              return LayoutBuilder(
                  builder: (context, BoxConstraints constraints){
                    return Stack(
                      children: [
                        AnimatedPositioned(
                            duration: listAnimationDuration,
                            top: controller.homeState == BasketState.cart
                                ? -(constraints.maxHeight -
                                cartBarHeight * 2 -
                                basketHeaderHeight)
                                : basketHeaderHeight,
                            left: 0,
                            right: 0,
                            height: constraints.maxHeight -
                                basketHeaderHeight -
                                cartBarHeight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(defaultPadding * 2),
                                  topRight: Radius.circular(defaultPadding * 2),
                                  bottomLeft:
                                  Radius.circular(defaultPadding * 2),
                                  bottomRight:
                                  Radius.circular(defaultPadding * 2),
                                ),
                              ),
                              // child: AddToListPage(tripDetails: tripDetails,controller: controller,),
                              child: AnimatedSwitcher(
                                duration: listAnimationDuration,
                                child: controller.homeState == BasketState.add
                                    ? Padding(
                                      padding: const EdgeInsets.all( 4.0),
                                      child: AddToListPage(tripDetails: tripDetails,controller: controller,),
                                    )
                                    :
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(SizeConfig.defaultPadding),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Full List:',style: Theme.of(context).textTheme.headline5,),
                                          Text('List of items your crew will bring.',style: Theme.of(context).textTheme.caption,),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: BringListToDisplay(tripDocID: tripDetails.documentId,)),
                                  ],
                                )
                              ),
                            )
                        ),
                        AnimatedPositioned(
                          duration: listAnimationDuration,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: controller.homeState == BasketState.cart
                              ? (constraints.maxHeight - cartBarHeight)
                              : cartBarHeight,
                          child: GestureDetector(
                            onVerticalDragUpdate: _onVerticalGesture,
                            child: Container(
                              padding: const EdgeInsets.all(defaultPadding),
                              color: canvasColor,
                              alignment: Alignment.topLeft,
                              child: AnimatedSwitcher(
                                duration: listAnimationDuration,
                                child: controller.homeState == BasketState.cart
                                    ? CartDetailsView(controller: controller,tripDetails: tripDetails,)
                                    : CartShortView(controller: controller)
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: listAnimationDuration,
                          top: controller.homeState == BasketState.cart
                              ? -basketHeaderHeight
                              : 0,
                          right: 0,
                          left: 0,
                          height: basketHeaderHeight,
                          child: BasketHeader(controller: controller,),
                        ),
                      ],
                    );
                  },
              );
            },
          ),
        ),
      ),
    );
  }

}