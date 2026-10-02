import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'safety_actions.dart';

class BlockedUsersScreen extends StatelessWidget {
  BlockedUsersScreen({super.key});
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CustomScaffold(
      className: 'BlockedUsersScreen',
      screenName: l.safetyBlockedUsers,
      scaffoldKey: _scaffoldKey,
      body: Obx(() {
        if (!SafetyService.ready.value) return const SafetyLoadingView();
        final ids = SafetyService.blockedIds.toList()..sort();
        if (ids.isEmpty) {
          return Center(
            child: Text(
              l.safetyNoBlockedUsers,
              style: AppStyles.labelTextStyle(),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: ids.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder:
              (_, index) => _BlockedUserTile(
                key: ValueKey(ids[index]),
                userId: ids[index],
              ),
        );
      }),
    );
  }
}

class _BlockedUserTile extends StatefulWidget {
  const _BlockedUserTile({super.key, required this.userId});
  final String userId;
  @override
  State<_BlockedUserTile> createState() => _BlockedUserTileState();
}

class _BlockedUserTileState extends State<_BlockedUserTile> {
  late final Future<PublicUserModel?> _profile =
      AuthService.getUserPublicProfile(userId: widget.userId);
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.kLightGreyColor),
      ),
      child: FutureBuilder<PublicUserModel?>(
        future: _profile,
        builder:
            (context, snapshot) => ListTile(
              leading: const Icon(
                Icons.block_outlined,
                color: AppColors.kPrimaryColor,
              ),
              title: Text(
                snapshot.data?.displayName ?? l.safetyUnavailableUser,
                style: AppStyles.labelTextStyle(),
              ),
              trailing: Obx(
                () => TextButton(
                  onPressed:
                      SafetyService.busyIds.contains(widget.userId)
                          ? null
                          : () => confirmBlock(context, widget.userId),
                  child: Text(l.safetyUnblock),
                ),
              ),
            ),
      ),
    );
  }
}
