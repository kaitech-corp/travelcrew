import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

import '../../../utils/app_colors.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required this.title,
    this.isNetworkImage = false,
    this.leadingImage,
    this.trailingIcon,
    this.backgroundColor = const Color(0xFFFAFAFA),
    this.borderColor = const Color(0xFFE7E7E7),
    this.iconBackgroundColor = const Color(0x331D7FC2),
    this.onTap,
    this.borderRadius = 21,
    this.padding,
  });
  final String title;
  final String? leadingImage;
  final bool isNetworkImage;
  final Widget? trailingIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            padding ?? EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor!),
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
        ),
        child: Row(
          children: [
            if (leadingImage != null)
              AnyImageView(
                width: title == 'Delete Account' ? 45.w : 48.w,
                height: title == 'Delete Account' ? 45.w : 48.h,
                borderRadius: BorderRadius.circular(12.r),
                containerBackgroundColor:
                    title == 'Delete Account'
                        ? AppColors.kPrimaryColor.withValues(alpha: .2)
                        : null,
                imageColor:
                    title == 'Delete Account' ? AppColors.kPrimaryColor : null,
                url: leadingImage ?? '',
                fileType:
                    isNetworkImage ? SourceType.network : SourceType.asset,
              ),
            if (leadingImage != null) SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito().copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.16,
                ),
              ),
            ),
            trailingIcon ??
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.black,
                ),
          ],
        ),
      ),
    );
  }
}
