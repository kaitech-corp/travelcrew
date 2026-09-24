import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/app_images.dart';

/// Google’s pre-approved light Sign in with Google artwork.
///
/// The image includes the required boundary, colored G, label, and spacing.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    return Semantics(
      button: true,
      label: 'Sign in with Google',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22.r),
        child: SizedBox(
          width: (isIos ? 188 : 180).w,
          height: (isIos ? 44 : 40).h,
          child: Image.asset(
            isIos
                ? AppImages.kGoogleSignInButtonIos
                : AppImages.kGoogleSignInButtonAndroid,
            fit: BoxFit.fill,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
