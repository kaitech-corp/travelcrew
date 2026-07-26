import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<_FeatureItem> features = [
      _FeatureItem(
        icon: LucideIcons.map,
        title: l10n.aboutFeatureTripManagement,
        subtitle: l10n.aboutFeatureTripManagementSub,
        color: AppColors.kPrimaryColor,
      ),
      _FeatureItem(
        icon: LucideIcons.users,
        title: l10n.aboutFeatureCrewCollab,
        subtitle: l10n.aboutFeatureCrewCollabSub,
        color: const Color(0xFF8B5CF6),
      ),
      _FeatureItem(
        icon: LucideIcons.checkSquare,
        title: l10n.aboutFeatureActivities,
        subtitle: l10n.aboutFeatureActivitiesSub,
        color: const Color(0xFF10B981),
      ),
      _FeatureItem(
        icon: LucideIcons.plane,
        title: l10n.aboutFeatureFlightsLodging,
        subtitle: l10n.aboutFeatureFlightsLodgingSub,
        color: const Color(0xFF06B6D4),
      ),
      _FeatureItem(
        icon: LucideIcons.dollarSign,
        title: l10n.aboutFeatureExpenseSplitting,
        subtitle: l10n.aboutFeatureExpenseSplittingSub,
        color: const Color(0xFFF59E0B),
      ),
      _FeatureItem(
        icon: LucideIcons.messageSquare,
        title: l10n.aboutFeatureGroupChat,
        subtitle: l10n.aboutFeatureGroupChatSub,
        color: const Color(0xFFEC4899),
      ),
      _FeatureItem(
        icon: LucideIcons.bell,
        title: l10n.aboutFeatureNotifications,
        subtitle: l10n.aboutFeatureNotificationsSub,
        color: const Color(0xFF6366F1),
      ),
      _FeatureItem(
        icon: LucideIcons.sparkles,
        title: l10n.aboutFeatureImportFromAi,
        subtitle: l10n.aboutFeatureImportFromAiSub,
        color: const Color(0xFF9333EA),
      ),
    ];

    final List<String> aiSteps = [
      l10n.aboutImportAiStep1,
      l10n.aboutImportAiStep2,
      l10n.aboutImportAiStep3,
      l10n.aboutImportAiStep4,
      l10n.aboutImportAiStep5,
    ];

    return CustomScaffold(
      screenName: l10n.about,
      scaffoldKey: _scaffoldKey,
      centerTitle: true,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      className: widget.runtimeType.toString(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header / Hero Section
            _buildHeroHeader(l10n),
            SizedBox(height: 24.h),

            // Features Section
            _buildSectionTitle(
              title: l10n.aboutFeaturesTitle,
              icon: LucideIcons.layers,
            ),
            SizedBox(height: 12.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = features[index];
                return _buildFeatureTile(item);
              },
            ),
            SizedBox(height: 24.h),

            // Import from AI Section
            _buildAiImportCard(l10n, aiSteps),
            SizedBox(height: 24.h),

            // Tech Stack & Footer Section
            _buildFooterSection(l10n),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Logo & Version Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.kAppLogo,
                height: 56.h,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.plane,
                    size: 30.sp,
                    color: AppColors.kPrimaryColor,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Crew',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: AppColors.kBlackColor,
                      fontSize: AppStyles.fontSize22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'v1.0.0',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kPrimaryColor,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Overview text
          Text(
            l10n.aboutContent1,
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black87,
              fontSize: AppStyles.fontSize14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColors.kPrimaryColor,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: AppStyles.fontSize18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(_FeatureItem item) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: item.color.withAlpha(25),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              item.icon,
              size: 22.sp,
              color: item.color,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: Colors.black,
                    fontSize: AppStyles.fontSize15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.subtitle,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: Colors.grey.shade700,
                    fontSize: AppStyles.fontSize13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiImportCard(AppLocalizations l10n, List<String> aiSteps) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3E8FF),
            Color(0xFFEFF6FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD8B4FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF9333EA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  LucideIcons.sparkles,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                l10n.aboutImportAiTitle,
                style: AppStyles.labelTextStyle().copyWith(
                  color: const Color(0xFF581C87),
                  fontSize: AppStyles.fontSize18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            l10n.aboutImportAiDesc,
            style: AppStyles.labelTextStyle().copyWith(
              color: const Color(0xFF3B0764),
              fontSize: AppStyles.fontSize13,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            l10n.aboutImportAiHowItWorks,
            style: AppStyles.labelTextStyle().copyWith(
              color: const Color(0xFF581C87),
              fontSize: AppStyles.fontSize14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          ...List.generate(aiSteps.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9333EA),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      aiSteps[index],
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFF4C1D95),
                        fontSize: AppStyles.fontSize13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooterSection(AppLocalizations l10n) {
    final techStack = ['Flutter', 'Firebase', 'GetX', 'Google Maps'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Built with',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.grey.shade600,
              fontSize: AppStyles.fontSize12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            alignment: WrapAlignment.center,
            children: techStack.map((tech) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  tech,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: Colors.grey.shade800,
                    fontSize: AppStyles.fontSize12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade300, height: 1),
          SizedBox(height: 12.h),
          Text(
            l10n.aboutContent4,
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.grey.shade600,
              fontSize: AppStyles.fontSize12,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'GNU General Public License v3.0',
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.grey.shade500,
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
