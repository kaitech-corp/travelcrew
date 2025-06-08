import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const SocialButton({super.key, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // color: Colors.grey[100],
        ),
        child: Center(child: Image.asset(icon, width: 24.w, height: 24.w)),
      ),
    );
  }
}
