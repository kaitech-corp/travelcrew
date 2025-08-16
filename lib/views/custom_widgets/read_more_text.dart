import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../utils/app_styles.dart';

class ReadMoreTextWidget extends StatelessWidget {
  const ReadMoreTextWidget({
    super.key,
    required this.text,
    this.trimMode,
    this.readLessText,
    this.readMoreText,
    this.trimLines = 2,
    this.textStyle,
    this.readLessTextStyle,
    this.readMoreTextStyle,
  });
  final String text;
  final TextStyle? textStyle;
  final TextStyle? readLessTextStyle;
  final TrimMode? trimMode;
  final TextStyle? readMoreTextStyle;
  final String? readMoreText;
  final String? readLessText;
  final int trimLines;
  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text,
      trimMode: trimMode ?? TrimMode.Line,
      trimLines: trimLines,
      trimCollapsedText: readMoreText ?? 'Show more',
      trimExpandedText: readLessText ?? 'Show less',
      style: textStyle ?? AppStyles.labelTextStyle().copyWith(fontSize: 12),
      lessStyle:
          readLessTextStyle ??
          AppStyles.labelTextStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
      moreStyle:
          readMoreTextStyle ??
          AppStyles.labelTextStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}
