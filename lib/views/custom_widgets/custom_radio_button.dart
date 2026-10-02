import 'package:flutter/material.dart';
import 'package:travel_crew/views/custom_widgets/text_widget.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class CustomRadioButton<T> extends StatelessWidget {
  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.text,
    required this.onChanged,
  });
  final T value;
  final T groupValue;
  final String text;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ignore: deprecated_member_use
          Radio<T>(value: value, groupValue: groupValue, onChanged: onChanged),
          TextWidget(
            labelText: text,
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: AppStyles.fontSize13,
              fontWeight: FontWeight.w400,
              color: AppColors().klabeltextcolor,
            ),
          ),
        ],
      ),
    );
  }
}
