import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PublicUserModel? _user;
  bool _isLoading = true;
  bool _isUpdatingFollow = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final argument = Get.arguments;
    final passedUser = argument is PublicUserModel ? argument : null;
    final userId = passedUser?.uid ?? (argument is String ? argument : null);

    if (userId == null || userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final user = await AuthService.getUserPublicProfile(userId: userId);
    if (!mounted) return;
    setState(() {
      _user = user ?? passedUser;
      _isLoading = false;
    });
  }

  bool get _isFollowing {
    final currentUserId = GlobalVariables.loggedInUser.value?.uid;
    return currentUserId != null &&
        (_user?.followers?.contains(currentUserId) ?? false);
  }

  Future<void> _toggleFollow() async {
    final user = _user;
    final currentUserId = GlobalVariables.loggedInUser.value?.uid;
    if (user == null || currentUserId == null || user.uid == currentUserId) {
      return;
    }

    setState(() => _isUpdatingFollow = true);
    final wasFollowing = _isFollowing;
    final success =
        wasFollowing
            ? await AuthService.unfollowUser(user.uid)
            : await AuthService.followUser(user.uid);

    if (!mounted) return;
    if (success) {
      final followers = List<String>.from(user.followers ?? []);
      if (wasFollowing) {
        followers.remove(currentUserId);
      } else if (!followers.contains(currentUserId)) {
        followers.add(currentUserId);
      }
      setState(() {
        user.followers = followers;
        _isUpdatingFollow = false;
      });
    } else {
      setState(() => _isUpdatingFollow = false);
      showCustomSnackBar(content: 'Could not update follow status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Profile',
      centerTitle: true,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? const Center(child: Text('Profile not found'))
              : _buildProfile(_user!),
    );
  }

  Widget _buildProfile(PublicUserModel user) {
    final isOwnProfile = user.uid == GlobalVariables.loggedInUser.value?.uid;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 28.h),
          AnyImageView(
            url: user.profileImage ?? '',
            height: 104.r,
            width: 104.r,
            isCircle: true,
            containerBackgroundColor: AppColors.kLightBlueColor,
          ),
          SizedBox(height: 14.h),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: AppStyles.fontSize22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (user.hometown?.isNotEmpty ?? false) ...[
            SizedBox(height: 6.h),
            Text(
              user.hometown!,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kGreyTextColor,
                fontSize: AppStyles.fontSize13,
              ),
            ),
          ],
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  count: user.followers?.length ?? 0,
                  label: 'Followers',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  count: user.following?.length ?? 0,
                  label: 'Following',
                ),
              ),
            ],
          ),
          if (!isOwnProfile) ...[
            SizedBox(height: 22.h),
            CustomElevatedButton(
              width: Get.width,
              height: 52.h,
              title: _isFollowing ? 'Following' : 'Follow',
              isDisabled: _isUpdatingFollow,
              isReversed: _isFollowing,
              backgroundColor:
                  _isFollowing
                      ? AppColors.kWhiteColor
                      : AppColors.kPrimaryColor,
              foregroundColor:
                  _isFollowing
                      ? AppColors.kPrimaryColor
                      : AppColors.kWhiteColor,
              reverseBorderColor: AppColors.kPrimaryColor,
              onPressed: _toggleFollow,
            ),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.kLightGreyColor),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: AppStyles.fontSize18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppStyles.labelTextStyle().copyWith(
              color: AppColors.kGreyTextColor,
              fontSize: AppStyles.fontSize12,
            ),
          ),
        ],
      ),
    );
  }
}
