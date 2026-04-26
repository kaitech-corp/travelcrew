import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/views/onboarding/widgets/page_indicator.dart';

import '../../../../models/onboarding_page_model.dart';
import '../../../utils/app_styles.dart';
import '../../custom_widgets/custom_elevated_button.dart';
import '../controller/onboarding_controller.dart';

class OnboardingPageWidget extends StatelessWidget {
  OnboardingPageWidget({super.key, required this.page, required this.index});
  final OnboardingController controller = Get.find<OnboardingController>();
  final OnboardingPage page;
  final int index;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(page.image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: BlurryContainer(
            blur: 7,
            color: Colors.black.withValues(alpha: .2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(42.01),
              topRight: Radius.circular(42.01),
            ),
            width: Get.width,
            padding: EdgeInsets.symmetric(
              horizontal: 21.01.w,
              vertical: 49.02.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    textAlign: TextAlign.center,
                    index == 0
                        ? l10n.onboardingTitle1
                        : index == 1
                        ? l10n.onboardingTitle2
                        : l10n.onboardingTitle3,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.white,
                      fontSize: AppStyles.fontSize28,

                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  index == 0
                      ? l10n.onboardingSubtitle1
                      : index == 1
                      ? l10n.onboardingSubtitle2
                      : l10n.onboardingSubtitle3,
                  textAlign: TextAlign.center,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: Colors.white.withValues(alpha: 140),
                    fontSize: AppStyles.fontSize15,

                    fontWeight: FontWeight.w500,
                    height: 1.33,
                  ),
                ),
                SizedBox(height: 21.h),
                PageIndicator(
                  currentIndex: index,
                  totalIndexes: controller.pages.length,
                ),
                SizedBox(height: 28.h),
                Center(
                  child: CustomElevatedButton(
                    width: Get.width * 0.6,
                    title: 'Next',
                    onPressed: controller.nextPage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
