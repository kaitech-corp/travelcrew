import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalIndexes;
  final double height;
  const PageIndicator({
    super.key,
    this.height = 21,
    required this.currentIndex,
    required this.totalIndexes,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalIndexes, (index) {
        final isSelected = currentIndex == index;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          width: isSelected ? height.w : 4.w,
          height: isSelected ? height.w : 4.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                isSelected
                    ? Border.all(color: Colors.white, width: .5.w)
                    : null,
            color: isSelected ? Colors.transparent : Colors.white,
          ),
          alignment: Alignment.center,
          child:
              isSelected
                  ? Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                  : const SizedBox.shrink(),
        );
      }),
    );
  }
}
