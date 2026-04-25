import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/views/profile/components/help_n_support/controller/help_n_support_controller.dart';
import 'package:travel_crew/views/profile/components/help_n_support/widget/help_n_support_widget.dart';

import '../../../custom_widgets/custom_scaffold.dart';

class HelpNSupportScreen extends GetView<HelpNSupportController> {
  const HelpNSupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.helpAndSupport,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      centerTitle: true,
      body: Column(
        spacing: 5.h,
        children: [
          SizedBox(height: 20.h),
          HelpSupportExpansionTile(
            title: l10n.safetyAndSecurity,
            description: l10n.safetyAndSecurityDescription,
          ),
        ],
      ),
    );
  }
}
