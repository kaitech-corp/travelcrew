import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/url_launcher_helper.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';

import '../../../../utils/app_styles.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.privacyPolicyAndTerms,
      scaffoldKey: _scaffoldKey,
      centerTitle: true,
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 25.h),
      className: 'Privacy Policy',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLinkTile(
              title: l10n.privacyPolicy,
              onTap: () => openExternalUrl(kPrivacyPolicyUrl),
            ),
            SizedBox(height: 16.h),
            _buildLinkTile(
              title: l10n.termsAndConditions,
              onTap: () => openExternalUrl(kTermsAndConditionsUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.black,
                  fontSize: AppStyles.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppColors.kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
