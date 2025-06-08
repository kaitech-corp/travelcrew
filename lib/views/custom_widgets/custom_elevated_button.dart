import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.width,
    this.foregroundColor,
    this.height = 52.02,
    required this.title,
    this.padding,
    this.icon,
    this.backgroundColor,
    required this.onPressed,
    this.isIcon = false,
    this.textStyle,
    this.isReversed = false,
    this.isShadow = true,
    this.iconStart,
    this.isDisabled = false,
    this.reverseBorderColor = AppColors.kSecondaryColor,
  });
  final TextStyle? textStyle;
  final double width;
  final Widget? icon;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double height;
  final String title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isIcon;
  final bool isReversed;
  final bool isShadow;
  final Widget? iconStart;
  final bool isDisabled;
  final Color? reverseBorderColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          isDisabled
              ? null
              : () {
                CommonCode().removeTextFieldFocus();
                onPressed.call();
              },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        elevation: isShadow ? 1 : 0,
        animationDuration: Duration(milliseconds: 500),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: isDisabled ? Colors.grey : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
          side:
              isReversed
                  ? BorderSide(
                    color: reverseBorderColor ?? AppColors.kSecondaryColor,
                    width: 0.7,
                  )
                  : BorderSide.none,
        ),
      ),
      child:
          isIcon
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconStart ?? SizedBox.shrink(),
                  SizedBox(width: 10.w),
                  Text(
                    title,
                    style:
                        textStyle ??
                        AppStyles.labelTextStyle().copyWith(
                          color: foregroundColor ?? AppColors.kWhiteColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(width: 10.w),
                  icon ?? SizedBox.shrink(),
                ],
              )
              : Text(
                title,
                style:
                    textStyle ??
                    AppStyles.labelTextStyle().copyWith(
                      fontSize: 16.sp,

                      fontWeight: FontWeight.w600,
                      color: foregroundColor ?? AppColors.kWhiteColor,
                    ),
              ),
    );
  }
}

class CustomButtonTwoIcon extends StatelessWidget {
  const CustomButtonTwoIcon({
    super.key,
    required this.width,
    this.foregroundColor,
    this.height = 46,
    required this.title,
    this.padding,
    required this.leadingIcon,
    required this.trailingIcon,
    this.backgroundColor,
    required this.onPressed,
    this.isReversed = false,
    this.isShadow = true,
    this.isDisabled = false,
  });
  final double width;
  final Widget leadingIcon;
  final Widget trailingIcon;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double height;
  final String title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isReversed;
  final bool isShadow;
  final bool isDisabled;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          isDisabled
              ? null
              : () {
                CommonCode().removeTextFieldFocus();
                onPressed.call();
              },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        elevation: isShadow ? 5 : 0,
        animationDuration: Duration(milliseconds: 500),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        backgroundColor: isDisabled ? Colors.grey : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
          side:
              isReversed
                  ? BorderSide(color: AppColors.kSecondaryColor, width: 0.7)
                  : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingIcon,
          SizedBox(width: 10.w),
          Text(
            title,
            style: AppStyles.labelTextStyle().copyWith(
              color: foregroundColor ?? AppColors.kWhiteColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10.w),
          trailingIcon,
        ],
      ),
    );
  }
}
