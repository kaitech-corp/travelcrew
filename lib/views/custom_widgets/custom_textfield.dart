import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/common_code.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField({
    super.key,
    this.alignment,
    this.width,
    this.margin,
    this.controller,
    this.onFieldSubmitted,
    required this.focusNode,
    this.nextFocusNode,
    this.labelText,
    this.labelStyle,
    this.autofocus = false,
    this.textStyle,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.onTapOutside,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.onEditingComplete,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = true,
    this.validator,
    this.phoneValidator,
    this.isViewMode = false,
    this.isPhoneNumber = false,
    this.showCursor,
    this.minLines,
    this.isLabel = true,
    this.onTap,
    this.onChanged,
    this.onCountryChanged,
  });
  final bool isLabel;
  final Alignment? alignment;
  final Function(PointerDownEvent)? onTapOutside;
  final double? width;
  final bool? showCursor;
  final EdgeInsetsGeometry? margin;
  final TextEditingController? controller;
  final String? labelText;
  final TextStyle? labelStyle;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool? autofocus;
  final TextStyle? textStyle;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final int? maxLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Function(String)? onFieldSubmitted;
  final BoxConstraints? prefixConstraints;
  TextCapitalization textCapitalization;
  final Widget? suffix;
  final int? minLines;
  final BoxConstraints? suffixConstraints;
  final EdgeInsets? contentPadding;
  final InputBorder? borderDecoration;
  final Function()? onEditingComplete;
  final Color? fillColor;
  final bool? filled;
  FutureOr<String?> Function(PhoneNumber?)? phoneValidator;
  final bool isViewMode;
  final bool isPhoneNumber;
  final Function(Country country)? onCountryChanged;
  ValueChanged? onChanged;
  VoidCallback? onTap;
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  Country? selectedCountry;
  @override
  void initState() {
    super.initState();
    selectedCountry = Country.parse('US');
  }

  @override
  Widget build(BuildContext context) {
    return widget.alignment != null
        ? Align(
          alignment: widget.alignment ?? Alignment.center,
          child: textFormFieldWidget,
        )
        : textFormFieldWidget;
  }

  Widget get textFormFieldWidget => Container(
    width: widget.width ?? double.maxFinite,
    margin: widget.margin ?? const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...{
          Text(
            widget.labelText ?? '',
            style:
                widget.labelStyle ??
                widget.textStyle ??
                AppStyles.labelTextStyle().copyWith(
                  fontSize: AppStyles.fontSize14,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 8),
        },
        widget.isPhoneNumber
            ? IntlPhoneField(
              initialCountryCode: 'PK',
              languageCode: 'ur',
              controller: widget.controller,
              validator: (p) {
                return widget.phoneValidator?.call(p);
              },
              focusNode: widget.focusNode,
              dropdownIconPosition: IconPosition.trailing,
              showCountryFlag: false,
              showDropdownIcon: false,
              onChanged: widget.onChanged,
              onCountryChanged: (v) {
                // widget.onCountryChanged?.call();
                // selectedCountry = v;
              },
              onSubmitted: widget.onFieldSubmitted,
              onTap: widget.onTap,
              decoration: decoration,
            )
            : TextFormField(
              minLines: widget.minLines,
              textCapitalization: TextCapitalization.sentences,
              showCursor: widget.showCursor,

              onTap: widget.onTap,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onEditingComplete: widget.onEditingComplete,
              readOnly: widget.isViewMode,
              controller: widget.controller,
              focusNode: widget.focusNode,
              style:
                  widget.textStyle ??
                  AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize14,
                    fontWeight: FontWeight.w400,
                  ),
              obscureText: widget.obscureText!,
              textInputAction: widget.textInputAction,
              keyboardType: widget.textInputType,
              maxLines: widget.maxLines ?? 1,
              decoration: decoration,
              onChanged: widget.onChanged,
              onFieldSubmitted:
                  widget.onFieldSubmitted ??
                  (value) {
                    if (widget.nextFocusNode != null) {
                      widget.nextFocusNode?.requestFocus();
                    }
                    if (widget.hintText == '1234 1234 1234 1234') {
                      widget.controller!.text = value;
                    }
                    if (widget.hintText == '07/12') {
                      widget.controller!.text = value;
                    }
                  },
              inputFormatters:
                  widget.hintText == '1234 1234 1234 1234'
                      ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CustomCreditCardFormatter(),
                      ]
                      : widget.hintText == '123'
                      ? [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ]
                      : (widget.hintText == '07/12'
                          ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                            CustomExpiryDateFormatter(),
                          ]
                          : null),
              onTapOutside:
                  widget.onTapOutside ??
                  (v) {
                    CommonCode().removeTextFieldFocus();
                  },
              validator: widget.validator,
            ),
      ],
    ),
  );
  InputDecoration get decoration => InputDecoration(
    labelText: widget.isLabel ? widget.hintText : null,
    labelStyle:
        widget.labelStyle ??
        AppStyles.labelTextStyle().copyWith(
          fontSize: AppStyles.fontSize14,
          fontWeight: FontWeight.w400,
        ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: widget.hintText ?? '',
    hintStyle:
        widget.hintStyle ??
        AppStyles.labelTextStyle().copyWith(
          fontSize: AppStyles.fontSize14,
          fontWeight: FontWeight.w400,
        ),
    prefixIcon: widget.prefix,
    prefixIconConstraints: widget.prefixConstraints,
    suffixIcon:
        widget.suffix ??
        (widget.isPhoneNumber
            ? GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: Get.context!,
                  onSelect: (b) {
                    setState(() {
                      selectedCountry = b;
                    });
                    widget.onCountryChanged?.call(b);
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCountry!.flagEmoji,
                    style: AppStyles.labelTextStyle().copyWith(fontSize: AppStyles.fontSize24),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
                ],
              ),
            )
            : const SizedBox.shrink()),
    suffixIconConstraints: widget.suffixConstraints,
    isDense: true,
    contentPadding: widget.contentPadding ?? const EdgeInsets.all(15),
    fillColor: AppColors.kWhiteColor,
    filled: widget.filled,
    border:
        widget.borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.grey,
          ), // Customize border color
        ),
    enabledBorder:
        widget.borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Colors.grey,
          ), // Customize border color
        ),
    focusedBorder:
        widget.borderDecoration ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xff21AF85),
            width: 2,
          ), // Highlight border when focused
        ),
  );
}

class CustomExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (text.length > 5) {
      // Limit the length to 5 characters
      text = text.substring(0, 5);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i == 1) {
        final month = int.tryParse(text.substring(0, i + 1)) ?? 0;
        if (month > 12) {
          // If the month is greater than 12, return the old value
          return oldValue;
        } else {
          buffer.write(text[i]);
        }
        buffer.write('/'); // Add slash after the second character
      } else {
        buffer.write(text[i]);
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CustomCreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (text.length > 19) {
      // Limit the length to 19 characters
      text = text.substring(0, 19);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' '); // Add space after every 4 digits
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
