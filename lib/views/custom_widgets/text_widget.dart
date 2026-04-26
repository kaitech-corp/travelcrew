import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import '../../../utils/app_styles.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.labelText,
    this.style,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.onTap,
  });
  final String labelText;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: onTap == null,
      child: InkWell(
        onTap: onTap,
        child: Text(
          labelText.tr,
          style: style ?? AppStyles.labelTextStyle(),
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          overflow: overflow,
          maxLines: maxLines,
        ),
      ),
    );
  }
}
