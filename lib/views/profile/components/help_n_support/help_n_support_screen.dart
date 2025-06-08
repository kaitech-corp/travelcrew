import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/views/profile/components/help_n_support/controller/help_n_support_controller.dart';
import 'package:travel_crew/views/profile/components/help_n_support/widget/help_n_support_widget.dart';

import '../../../custom_widgets/custom_scaffold.dart';

class HelpNSupportScreen extends GetView<HelpNSupportController> {
  const HelpNSupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Help & Support',
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      centerTitle: true,
      body: Column(
        spacing: 5.h,
        children: [
          SizedBox(height: 20.h),
          HelpSupportExpansionTile(
            title: 'Safety & Security',
            description:
                "We protect your data with SSL encryption, ensuring secure transactions at Afriva.com. You're covered for unauthorized credit card use.",
          ),
          HelpSupportExpansionTile(
            title: 'Returns & Refunds',
            description:
                'Follow our return policy for fast processing. Contact warranty providers...',
          ),
          HelpSupportExpansionTile(
            title: 'Returns & Refunds',
            description:
                "Follow our return policy for fast processing. Contact warranty providers for defective products first. For other returns, a Return Merchandise Authorization (RMA#) is required.",
          ),
        ],
      ),
    );
  }
}
