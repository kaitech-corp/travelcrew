import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.width,
    this.foregroundColor,
    this.height = 50,
    required this.title,
    this.padding,
    this.icon,
    this.borderColor,
    this.textStyle,
    this.backgroundColor,
    required this.onPressed,
    this.isIcon = false,
  });
  final TextStyle? textStyle;
  final double width;
  final Widget? icon;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double height;
  final String title;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool isIcon;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        CommonCode().removeTextFieldFocus();
        onPressed.call();
      },
      style: TextButton.styleFrom(
        minimumSize: Size(width, height),
        elevation: 6,
        tapTargetSize: MaterialTapTargetSize.padded,
        animationDuration: const Duration(milliseconds: 500),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: borderColor ?? Theme.of(context).colorScheme.surface,
          ),
          borderRadius: BorderRadius.circular(50.r),
        ),
      ),
      child:
          isIcon
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style:
                        textStyle ??
                        AppStyles.labelTextStyle().copyWith(
                          color: foregroundColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(width: 10.w),
                  icon ??
                      Icon(weight: 20, Icons.arrow_forward_ios, size: 12.sp),
                ],
              )
              : Text(
                title,
                style:
                    textStyle ??
                    AppStyles.labelTextStyle().copyWith(
                      fontSize: 14.sp,
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
    );
  }
}
