import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.contentPadding,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.fillColor,
    this.width,
    this.height,
  });
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;
  final TextInputAction textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final Color? fillColor;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final double? width;
  final double? height;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode? focusNode;
  bool _ownsFocusNode = false;
  Color? fillColor;

  @override
  void initState() {
    super.initState();
    fillColor = widget.fillColor ?? AppColors.kLightGreyColor;
    _setFocusNode(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      focusNode?.removeListener(onFocus);
      if (_ownsFocusNode) {
        focusNode?.dispose();
      }
      _setFocusNode(widget.focusNode);
    }
  }

  void _setFocusNode(FocusNode? externalFocusNode) {
    _ownsFocusNode = externalFocusNode == null;
    focusNode = externalFocusNode ?? FocusNode();
    focusNode!.addListener(onFocus);
  }

  @override
  void dispose() {
    focusNode?.removeListener(onFocus);
    if (_ownsFocusNode) {
      focusNode?.dispose();
    }
    super.dispose();
  }

  void onFocus() {
    if (focusNode!.hasFocus) {
      setState(() {
        fillColor = AppColors.kWhiteColor;
      });
    } else {
      setState(() {
        fillColor = AppColors.kLightGreyColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: TextFormField(
        onFieldSubmitted: widget.onFieldSubmitted,
        focusNode: focusNode,
        textInputAction: widget.textInputAction,
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        style: AppStyles.labelTextStyle().copyWith(
          fontSize: AppStyles.fontSize16,
          color: Colors.black87,
        ),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorMaxLines: 2,
          hintStyle: AppStyles.labelTextStyle().copyWith(
            fontSize: AppStyles.fontSize16,
            fontWeight: FontWeight.w500,
            height: 1.25,
            color: Colors.grey[600],
          ),
          prefixIconConstraints: widget.prefixIconConstraints,
          suffixIconConstraints: widget.suffixIconConstraints,
          prefixIcon:
              widget.prefixIcon != null
                  ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: widget.prefixIcon,
                  )
                  : null,
          suffixIcon:
              widget.suffixIcon != null
                  ? Padding(
                    padding: EdgeInsets.all(12.w),
                    child: widget.suffixIcon,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColors.kPrimaryColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColors.kRedColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColors.kRedColor),
          ),
          filled: true,
          fillColor: fillColor,
          contentPadding:
              widget.contentPadding ??
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        ),
      ),
    );
  }
}
