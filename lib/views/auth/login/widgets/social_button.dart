import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.icon, required this.onTap});
  final String icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          // color: Colors.grey[100],
        ),
        child: Padding(
          padding: EdgeInsets.all(9.w),
          child: Image.asset(icon, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
