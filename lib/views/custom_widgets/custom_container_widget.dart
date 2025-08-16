import 'package:flutter/cupertino.dart';
import '../../../../utils/app_colors.dart';
class CustomContainerWidget extends StatelessWidget {
  const CustomContainerWidget({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final Function()? onTap;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;
  final double? borderRadius;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: AppColors.kWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20),
          ),
        ),
        child: child,
      ),
    );
  }
}
