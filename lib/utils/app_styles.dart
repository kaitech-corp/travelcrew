import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppStyles {

  static TextStyle labelTextStyle() => GoogleFonts.urbanist(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.kBlackColor,
  );
  static TextStyle appBarHeadingTextStyle() => GoogleFonts.urbanist(
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static ButtonStyle get fillPrimary => ElevatedButton.styleFrom(
    backgroundColor: AppColors.kPrimaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
  );
}
