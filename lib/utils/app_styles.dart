import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {
  // Font Sizes — minimum size is 12.sp
  static double get fontSize12 => 12.sp;
  static double get fontSize13 => 13.sp;
  static double get fontSize14 => 14.sp;
  static double get fontSize15 => 15.sp;
  static double get fontSize16 => 16.sp;
  static double get fontSize17 => 17.sp;
  static double get fontSize18 => 18.sp;
  static double get fontSize20 => 20.sp;
  static double get fontSize22 => 22.sp;
  static double get fontSize24 => 24.sp;
  static double get fontSize28 => 28.sp;

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
