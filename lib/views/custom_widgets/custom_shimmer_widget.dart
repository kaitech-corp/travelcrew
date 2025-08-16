import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class CustomShimmerWidget extends StatelessWidget {
  const CustomShimmerWidget(
      {super.key,
      this.height = 80,
      this.padding,
      this.isScrollable = true,
      this.width = 80,
      this.applyShimmerFromHere = true,
      this.customWidget,
      this.childAspectRatio = 0.7,
      this.crossAxisCount = 2,
      this.mainAxisSpacing = 10,
      this.crossAxisSpacing = 10,
      this.borderRadius,
      this.isCircle = true,
      this.isListview = true,
      this.scrollDirection = Axis.horizontal,
      this.itemCount = 10});
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final Widget? customWidget;
  final bool isScrollable;
  final double crossAxisSpacing;
  final bool isListview;
  final int crossAxisCount;
  final bool applyShimmerFromHere;
  final double childAspectRatio;
  final Axis scrollDirection;
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return padding != null
        ? Padding(
            padding: padding!,
            child: getMain(),
          )
        : getMain();
  }
  BoxScrollView getMain() {
    return isListview
        ? ListView.separated(
            shrinkWrap: true,
            physics: isScrollable
                ? const ScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
              height: scrollDirection == Axis.horizontal ? 0 : mainAxisSpacing,
              width: scrollDirection == Axis.vertical ? 0 : mainAxisSpacing,
            ),
            scrollDirection: scrollDirection,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return getWidget();
            },
          )
        : GridView.builder(
            shrinkWrap: true,
            physics: isScrollable
                ? const ScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return getWidget();
            },
          );
  }
  Widget getWidget() {
    return applyShimmerFromHere
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: customWidget ??
                Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle
                        ? null
                        : borderRadius ?? BorderRadius.circular(10),
                  ),
                ),
          )
        : customWidget ??
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius:
                    isCircle ? null : borderRadius ?? BorderRadius.circular(10),
              ),
            );
  }
}
