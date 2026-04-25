import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {
  // Font Sizes — minimum size is 12.sp
  static final double fontSize12 = 12.sp;
  static final double fontSize13 = 13.sp;
  static final double fontSize14 = 14.sp;
  static final double fontSize15 = 15.sp;
  static final double fontSize16 = 16.sp;
  static final double fontSize17 = 17.sp;
  static final double fontSize18 = 18.sp;
  static final double fontSize20 = 20.sp;
  static final double fontSize22 = 22.sp;
  static final double fontSize24 = 24.sp;
  static final double fontSize28 = 28.sp;

  static TextStyle labelTextStyle() => GoogleFonts.urbanist(
        fontSize: fontSize14,
        fontWeight: FontWeight.w400,
        color: AppColors.kBlackColor,
      );
  static TextStyle appBarHeadingTextStyle() => GoogleFonts.urbanist(
        fontSize: fontSize24,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      );
  static ButtonStyle get fillPrimary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.kPrimaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
  );
}
