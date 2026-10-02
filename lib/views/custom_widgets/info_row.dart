import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_crew/views/custom_widgets/text_widget.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.text, this.icon});
  final String text;
  final Widget? icon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10.w,
        children: [
          icon ?? const Icon(Icons.info_outline, size: 15),
          SizedBox(
            // width: MediaQuery.of(context).size.width * 0.8,
            child: TextWidget(
              labelText: text,
              maxLines: 3,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors().klabeltextcolor,
                fontSize: AppStyles.fontSize14,
                fontWeight: FontWeight.w400,
                height: 1.92,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
