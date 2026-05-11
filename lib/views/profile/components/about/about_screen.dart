import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';

import '../../../../utils/app_styles.dart';

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
    return CustomScaffold(
      screenName: l10n.about,
      scaffoldKey: _scaffoldKey,
      centerTitle: true,
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 25.h),
      className: widget.runtimeType.toString(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Title
            Text(
              l10n.aboutTitle,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: AppStyles.fontSize22,

                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),

            // About Content
            Text(
              l10n.aboutContent1,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: AppStyles.fontSize15,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.aboutContent2,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: AppStyles.fontSize15,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.aboutContent3,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: AppStyles.fontSize15,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.aboutContent4,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: AppStyles.fontSize15,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
