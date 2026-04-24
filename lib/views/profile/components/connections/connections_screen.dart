import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/app_styles.dart';
import 'controller/connections_controller.dart';

class ConnectionsScreen extends GetView<ConnectionsController> {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      initialIndex: controller.initialIndex.value,
      child: CustomScaffold(
        screenName: l10n.social, // Use a generic title or dynamic one
        centerTitle: true,
        scaffoldKey: controller.scaffoldKey,
        className: runtimeType.toString(),
        body: Column(
          children: [
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: l10n.followers),
                Tab(text: l10n.following),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TabBarView(
                  children: [
                    _buildUserList(controller.followers, l10n.noFollowersFound),
                    _buildUserList(controller.following, l10n.noFollowingFound),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<PublicUserModel> users, String emptyMessage) {
    if (users.isEmpty) {
      return Center(child: Text(emptyMessage));
    }
    return ListView.separated(
      padding: EdgeInsets.all(20.r),
      itemCount: users.length,
      separatorBuilder: (context, index) => SizedBox(height: 15.h),
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: AnyImageView(
            url: user.profileImage ?? '',
            height: 50.r,
            width: 50.r,
            isCircle: true,
          ),
          title: Text(
            user.displayName,
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            // Navigate to public profile of this user
            // Get.toNamed(kPublicProfileScreenRoute, arguments: user.uid);
          },
        );
      },
    );
  }
}
