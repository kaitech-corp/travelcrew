import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/transport_tab.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

import '../../../custom_widgets/custom_scaffold.dart';
import '../../../messages/users/controller/users_controller.dart';
import '../../../onboarding/widgets/page_indicator.dart';
import 'components/activities_tab.dart';
import 'components/lodging_tab.dart';

class SpecificTripViewScreen extends StatefulWidget {
  const SpecificTripViewScreen({super.key});

  @override
  State<SpecificTripViewScreen> createState() => _SpecificTripViewScreenState();
}

class _SpecificTripViewScreenState extends State<SpecificTripViewScreen> {
  final SpecificTripViewController controller =
      Get.find<SpecificTripViewController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {
    'Overview': GlobalKey(),
    'Crew': GlobalKey(),
    'Activities': GlobalKey(),
    'Flights': GlobalKey(),
    'Lodging': GlobalKey(),
    'Expenses': GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    controller.initializeFromArgument(Get.arguments);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    final key = _sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      onWillPop: () {
        if (Navigator.canPop(context)) {
          Get.back();
        } else {
          Get.offAllNamed(kMainViewScreenRoute);
          // Get.close(1);
        }
      },
      screenName: '',
      isBackIcon: false,
      leadingWidth: 0,
      isFullBody: true,
      appBarSize: 0,
      padding: EdgeInsets.zero,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      body: Obx(
        () =>
            controller.tripModel.value == null &&
                    controller.discoveryModel.value == null
                ? const SizedBox()
                : controller.isPublicPreview
                ? _buildPublicPreview(context)
                : Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderImage(context),
                          _buildJumpNav(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('Overview'),
                                _buildOverviewSection(),

                                _buildSectionHeader('Crew'),
                                _buildCrewSection(),

                                _buildSectionHeader(
                                  'Activities',
                                  onAdd: () {
                                    Get.toNamed(
                                      kAddActivityScreenRoute,
                                      arguments: {
                                        'tripId':
                                            controller.tripModel.value?.id,
                                        'toAdd': true,
                                        'onAdded': (activity) {
                                          controller
                                              .tripModel
                                              .value
                                              ?.activities ??= [];
                                          controller.tripModel.value?.activities
                                              ?.add(activity);
                                          controller.tripModel.refresh();
                                        },
                                      },
                                    );
                                  },
                                ),
                                ActivitiesTab(controller: controller),

                                _buildSectionHeader(
                                  'Flights',
                                  onAdd: () => _showAddFlightSheet(context),
                                ),
                                TransportTab(controller: controller),

                                _buildSectionHeader(
                                  'Lodging',
                                  onAdd:
                                      () => Get.toNamed(
                                        kAddLodgingScreenRoute,
                                        arguments: controller.tripModel.value,
                                      ),
                                ),
                                LodgingTab(controller: controller),

                                _buildSectionHeader(
                                  'Expenses',
                                  onAdd:
                                      () => Get.toNamed(
                                        kAddExpenseScreenRoute,
                                        arguments: {
                                          'tripId':
                                              controller.tripModel.value?.id,
                                          'trip': controller.tripModel.value,
                                          'tripMembers':
                                              controller
                                                  .tripModel
                                                  .value
                                                  ?.joindUsersList ??
                                              [],
                                          'onAdd': (expense) {
                                            controller
                                                .tripModel
                                                .value
                                                ?.expenses ??= [];
                                            controller.tripModel.value?.expenses
                                                ?.add(expense);
                                            controller.tripModel.refresh();
                                          },
                                        },
                                      ),
                                ),
                                _buildExpenseSummary(),
                                SizedBox(height: 12.h),
                                Obx(() => _buildSettlementCard(context)),

                                SizedBox(height: 100.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      left: 18.w,
                      right: 18.w,
                      child: CustomElevatedButton(
                        width: Get.width,
                        height: Get.height * 0.06,
                        title:
                            controller.tripModel.value?.joinedUsers?.any(
                                      (element) =>
                                          element ==
                                          GlobalVariables
                                              .loggedInUser
                                              .value!
                                              .uid,
                                    ) ??
                                    false
                                ? 'Open Chat'
                                : 'Send Message',
                        onPressed: () async {
                          late UsersController usersController;
                          if (!Get.isRegistered<UsersController>()) {
                            usersController = Get.put(UsersController());
                          } else {
                            usersController = Get.find<UsersController>();
                          }
                          usersController.currentTrip.value =
                              controller.tripModel.value;

                          usersController.listenToChat();

                          await Get.toNamed(kMessagesScreenRoute);
                          await usersController.stopListeningToChat();
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPublicPreview(BuildContext context) {
    final trip = controller.discoveryModel.value!;
    final requestStatus = controller.joinRequestStatus.value;
    final hasPendingRequest = requestStatus == 'pending';
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: Get.height * 0.45,
            child: Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height * 0.45,
                  color: Colors.black,
                ),
                AnyImageView(
                  width: Get.width,
                  height: Get.height * 0.45,
                  url: trip.images.isNotEmpty ? trip.images.first : '',
                ),
                Positioned(
                  top: 40.h,
                  left: 10.w,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: BlurryContainer(
                      padding: EdgeInsets.all(10.sp),
                      blur: 7,
                      height: 51.14.h,
                      width: 51.14.w,
                      color: Colors.black.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(50),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.kWhiteColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.title ?? trip.destination,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: const Color(0xFF0F0F0F),
                    fontSize: AppStyles.fontSize22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF1D7FC2),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        '${trip.destination}, ${trip.country}',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: const Color(0xFF1D7FC2),
                          fontSize: AppStyles.fontSize15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildPreviewInfoRow(
                  icon: LucideIcons.calendar,
                  label:
                      '${DateFormat('MMM d, yyyy').format(trip.effectiveStartDate)}'
                      '${trip.tripEndDate == null ? '' : ' - ${DateFormat('MMM d, yyyy').format(trip.tripEndDate!)}'}',
                ),
                SizedBox(height: 10.h),
                _buildPreviewInfoRow(
                  icon: LucideIcons.users,
                  label: '${trip.memberCount} people going',
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.sp),
                  decoration: BoxDecoration(
                    color: AppColors.kLightGreyColor,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    'Request to join this trip to see the itinerary, lodging, flights, crew, expenses, and chat.',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF77818D),
                      fontSize: AppStyles.fontSize14,
                      height: 1.35,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomElevatedButton(
                  width: double.infinity,
                  title:
                      hasPendingRequest ? 'Cancel Request' : 'Request to Join',
                  onPressed:
                      hasPendingRequest
                          ? controller.cancelPublicJoinRequest
                          : controller.requestToJoinPublicPreview,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewInfoRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: Colors.black54),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: AppStyles.labelTextStyle().copyWith(
              color: const Color(0xFF0F0F0F),
              fontSize: AppStyles.fontSize14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.45,
      child: PageView.builder(
        itemCount: controller.tripModel.value?.images.length ?? 0,
        itemBuilder:
            (c, index) => Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height * 0.45,
                  color: Colors.black,
                ),
                AnyImageView(
                  width: Get.width,
                  height: Get.height * 0.45,
                  url: controller.tripModel.value?.images[index] ?? '',
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Row(
                      children: [
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: BlurryContainer(
                            padding: EdgeInsets.all(10.sp),
                            blur: 7,
                            height: 51.14.h,
                            width: 51.14.w,
                            color: Colors.black.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(50),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: AppColors.kWhiteColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (c) => Stack(
                                    children: [
                                      SizedBox(
                                        height: context.height,
                                        width: context.width,
                                      ),
                                      Positioned(
                                        top: 60.h,
                                        right: 30.w,
                                        child: SizedBox(
                                          width: 204.07.w,
                                          child: BlurryContainer(
                                            blur: 7,
                                            color: Colors.black.withValues(
                                              alpha: .15,
                                            ),
                                            padding: EdgeInsets.all(11.sp),
                                            child: Column(
                                              spacing: 7.h,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (GlobalVariables.isLoggedInUser(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.createdBy ??
                                                      '',
                                                ))
                                                  MoreVertDialogueWidget(
                                                    title: 'Edit Trip',
                                                    onTap: () {
                                                      Get.back();
                                                      Get.offAndToNamed(
                                                        kCreateTripScreenRoute,
                                                        arguments:
                                                            controller
                                                                .tripModel
                                                                .value,
                                                      );
                                                    },
                                                    imagePath:
                                                        AppImages.kIcEditTrip,
                                                  ),
                                                if (GlobalVariables.isLoggedInUser(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.createdBy ??
                                                      '',
                                                ))
                                                  MoreVertDialogueWidget(
                                                    title: 'Invite',
                                                    onTap: () {
                                                      Get.back();
                                                      controller.inviteToTrip();
                                                    },
                                                    iconData:
                                                        LucideIcons.userPlus,
                                                  ),
                                                if (!GlobalVariables.isLoggedInUser(
                                                      controller
                                                              .tripModel
                                                              .value
                                                              ?.createdBy ??
                                                          '',
                                                    ) &&
                                                    !(controller
                                                            .tripModel
                                                            .value
                                                            ?.joinedUsers
                                                            ?.contains(
                                                              GlobalVariables
                                                                  .loggedInUser
                                                                  .value
                                                                  ?.uid,
                                                            ) ??
                                                        false))
                                                  MoreVertDialogueWidget(
                                                    title: 'Request to Join',
                                                    onTap: () {
                                                      Get.back();
                                                      controller.joinTrip();
                                                    },
                                                    iconData: LucideIcons.plus,
                                                  ),
                                                MoreVertDialogueWidget(
                                                  imagePath:
                                                      AppImages.kIcShareTrip,
                                                  title: 'Share Trip',
                                                  onTap: () async {
                                                    Get.back();
                                                    await SharePlus.instance.share(
                                                      ShareParams(
                                                        text:
                                                            'Check out this trip I found on Travel Crew!',
                                                        subject:
                                                            'Travel Crew Trip',
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (GlobalVariables.isLoggedInUser(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.createdBy ??
                                                      '',
                                                ))
                                                  MoreVertDialogueWidget(
                                                    title: 'Remove',
                                                    onTap: () {
                                                      Get.back();
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (c) => AlertDialog(
                                                              title: const Text(
                                                                'Are you sure you want to delete this trip?',
                                                              ),
                                                              content: const Text(
                                                                'This action cannot be undone.',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Get.back();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                        'Cancel',
                                                                      ),
                                                                ),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    controller
                                                                        .removeTrip();
                                                                    Get.back();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                        'Delete',
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                    },
                                                    iconData:
                                                        LucideIcons.trash2,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          child: BlurryContainer(
                            padding: EdgeInsets.all(10.sp),
                            blur: 7,
                            height: 51.14.h,
                            width: 51.14.w,
                            color: Colors.black.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(50),
                            child: const Icon(
                              Icons.more_vert,
                              color: AppColors.kWhiteColor,
                              size: 25,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: PageIndicator(
                      currentIndex: index,
                      totalIndexes:
                          controller.tripModel.value?.images.length ?? 0,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildJumpNav() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Row(
        children:
            _sectionKeys.keys.map((section) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ActionChip(
                  label: Text(section),
                  onPressed: () => _scrollToSection(section),
                  backgroundColor: AppColors.kLightGreyColor,
                  labelStyle: AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAdd}) {
    return Column(
      key: _sectionKeys[title],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            Text(
              title,
              style: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF0F0F0F),
                fontSize: AppStyles.fontSize18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (onAdd != null)
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle, color: Colors.blue),
              ),
          ],
        ),
        const Divider(),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.tripModel.value?.title ?? '',
          style: AppStyles.labelTextStyle().copyWith(
            color: const Color(0xFF0F0F0F),
            fontSize: AppStyles.fontSize22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Image.asset(AppImages.kPinLocation, scale: 4),
            SizedBox(width: 5.w),
            Text(
              controller.tripModel.value?.country ?? '',
              style: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF1D7FC2),
                fontSize: AppStyles.fontSize15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          'Description',
          style: AppStyles.labelTextStyle().copyWith(
            color: const Color(0xFF0F0F0F),
            fontSize: AppStyles.fontSize17,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          controller.tripModel.value?.tripLocation ?? '',
          style: AppStyles.labelTextStyle().copyWith(
            color: const Color(0xFF77818D),
            fontSize: AppStyles.fontSize15,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 15.h),
        _buildDateCard(),
      ],
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 0.20, color: Color(0xFFD2D5D9)),
          borderRadius: BorderRadius.circular(19),
        ),
      ),
      child: Row(
        children: [
          _buildDateColumn(
            'Trip Start',
            controller.tripModel.value?.tripStartDate,
          ),
          SizedBox(width: 20.w),
          _buildDateColumn('Trip End', controller.tripModel.value?.tripEndDate),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String title, DateTime? date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.labelTextStyle().copyWith(
            color: const Color(0xFF0F0F0F),
            fontSize: AppStyles.fontSize15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Image.asset(AppImages.kCalendarIcon, scale: 5),
            SizedBox(width: 5.w),
            Text(
              DateFormat('dd MMM yyyy').format(date ?? DateTime.now()),
              style: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFFA4ABB3),
                fontSize: AppStyles.fontSize12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCrewSection() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${controller.tripModel.value?.joindUsersList?.length ?? 0}',
              style: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF0F0F0F),
                fontSize: AppStyles.fontSize22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              'People Going',
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize13,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Obx(
          () =>
              controller.tripModel.value?.joindUsersList?.isEmpty ?? true
                  ? const Text('No one joined yet')
                  : SizedBox(
                    height: 60.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          controller.tripModel.value?.joindUsersList?.length ??
                          0,
                      itemBuilder: (context, index) {
                        final user =
                            controller.tripModel.value!.joindUsersList![index];
                        return Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: GestureDetector(
                            onTap: () => _showCrewMemberSheet(context, user),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.profileImage ?? '',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        ),
        if (GlobalVariables.isLoggedInUser(
          controller.tripModel.value?.createdBy ?? '',
        ))
          _buildJoinRequestsSection(),
      ],
    );
  }

  Widget _buildJoinRequestsSection() {
    final tripId = controller.tripModel.value?.id;
    if (tripId == null) return const SizedBox.shrink();
    return StreamBuilder(
      stream: FirebaseTripService.watchJoinRequests(tripId),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 18.h),
            Text(
              'Join Requests',
              style: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF0F0F0F),
                fontSize: AppStyles.fontSize16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            ...requests.map((request) {
              return FutureBuilder<PublicUserModel?>(
                future: AuthService.getUserPublicProfile(
                  userId: request.userId,
                ),
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data;
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: AppColors.kLightGreyColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              user?.profileImage?.isNotEmpty == true
                                  ? NetworkImage(user!.profileImage!)
                                  : null,
                          child:
                              user?.profileImage?.isNotEmpty == true
                                  ? null
                                  : const Icon(Icons.person),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            user?.displayName ?? 'Pending traveler',
                            style: AppStyles.labelTextStyle().copyWith(
                              fontSize: AppStyles.fontSize14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed:
                              () =>
                                  controller.rejectJoinRequest(request.userId),
                          child: const Text('Reject'),
                        ),
                        TextButton(
                          onPressed:
                              () =>
                                  controller.acceptJoinRequest(request.userId),
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showCrewMemberSheet(BuildContext context, PublicUserModel user) {
    final fullName = [
      user.firstName,
      user.lastName,
    ].where((p) => p != null && p.isNotEmpty).join(' ');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 36.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                CircleAvatar(
                  radius: 44.r,
                  backgroundImage:
                      (user.profileImage?.isNotEmpty == true)
                          ? NetworkImage(user.profileImage!)
                          : null,
                  backgroundColor: AppColors.kLightGreyColor,
                  child:
                      (user.profileImage?.isNotEmpty != true)
                          ? Icon(Icons.person, size: 44.r, color: Colors.grey)
                          : null,
                ),
                SizedBox(height: 14.h),
                Text(
                  user.displayName,
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                if (fullName.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    fullName,
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: AppStyles.fontSize16,
                      color: Colors.black54,
                    ),
                  ),
                ],
                if (user.hometown?.isNotEmpty == true) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 14.r,
                        color: Colors.black38,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        user.hometown!,
                        style: AppStyles.labelTextStyle().copyWith(
                          fontSize: AppStyles.fontSize14,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 6.h),
              ],
            ),
          ),
    );
  }

  Widget _buildExpenseSummary() {
    final totalBudget = controller.tripModel.value?.tripBudget ?? 0.0;
    final totalSpent =
        controller.tripModel.value?.expenses?.fold(
          0.0,
          (sum, e) => sum + e.amount,
        ) ??
        0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kLightGreyColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Budget'),
              Text('\$${totalBudget.toStringAsFixed(2)}'),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Spent'),
              Text(
                '\$${totalSpent.toStringAsFixed(2)}',
                style: TextStyle(
                  color: totalSpent > totalBudget ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddFlightSheet(BuildContext context) {
    controller.clearFlightForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Add Your Flight',
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: AppStyles.fontSize18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    controller: controller.flightAirlineController,
                    hintText: 'Airline name',
                  ),
                  SizedBox(height: 12.h),
                  CustomTextField(
                    controller: controller.flightNumberController,
                    hintText: 'Flight number',
                  ),
                  SizedBox(height: 12.h),
                  CustomTextField(
                    controller: controller.flightDepartureAirportController,
                    hintText: 'Departure airport',
                  ),
                  SizedBox(height: 12.h),
                  CustomTextField(
                    controller: controller.flightArrivalAirportController,
                    hintText: 'Arrival airport',
                  ),
                  SizedBox(height: 12.h),
                  Obx(
                    () => _buildDateTile(
                      label:
                          controller.flightDepartureDate.value == null
                              ? 'Departure date'
                              : 'Departure: ${DateFormat('MMM dd, yyyy').format(controller.flightDepartureDate.value!)}',
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          controller.flightDepartureDate.value = picked;
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => _buildDateTile(
                      label:
                          controller.flightArrivalDate.value == null
                              ? 'Arrival date'
                              : 'Arrival: ${DateFormat('MMM dd, yyyy').format(controller.flightArrivalDate.value!)}',
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          controller.flightArrivalDate.value = picked;
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomElevatedButton(
                    width: double.infinity,
                    title: 'Add Flight',
                    onPressed: () => controller.addFlight(),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDateTile({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.kLightGreyColor,
          borderRadius: BorderRadius.circular(27.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppStyles.labelTextStyle().copyWith(
                  fontSize: AppStyles.fontSize13,
                  color: Colors.black54,
                ),
              ),
            ),
            Image.asset(
              AppImages.kCalendarIcon,
              scale: 5,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementCard(BuildContext context) {
    final currentUid = GlobalVariables.loggedInUser.value?.uid ?? '';
    final settlements = controller.optimalSettlements;
    final users = controller.tripModel.value?.joindUsersList ?? [];

    String nameFor(String uid) {
      if (uid == currentUid) return 'You';
      try {
        return users.firstWhere((u) => u.uid == uid).displayName;
      } catch (_) {
        return uid.substring(0, 6);
      }
    }

    if (settlements.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4AD10B).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4AD10B)),
            SizedBox(width: 10.w),
            Text(
              'All settled up!',
              style: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF4AD10B),
                fontWeight: FontWeight.w600,
                fontSize: AppStyles.fontSize14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          settlements.map((s) {
            final isCurrentUserPaying = s.fromUserId == currentUid;
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isCurrentUserPaying
                        ? const Color(0xFFFFEBEB)
                        : AppColors.kLightGreyColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          nameFor(s.fromUserId),
                          style: AppStyles.labelTextStyle().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppStyles.fontSize13,
                            color:
                                isCurrentUserPaying
                                    ? const Color(0xFFD9534F)
                                    : const Color(0xFF1F1F1F),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          nameFor(s.toUserId),
                          style: AppStyles.labelTextStyle().copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppStyles.fontSize13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${s.amount.toStringAsFixed(2)}',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF1D7FC2),
                      fontWeight: FontWeight.w700,
                      fontSize: AppStyles.fontSize13,
                    ),
                  ),
                  if (isCurrentUserPaying) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap:
                          () => showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Mark as Paid'),
                                  content: Text(
                                    'Confirm you have paid ${nameFor(s.toUserId)} \$${s.amount.toStringAsFixed(2)}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: Get.back,
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.markSettlementPaid(
                                          s.fromUserId,
                                        );
                                      },
                                      child: const Text('Confirm'),
                                    ),
                                  ],
                                ),
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D7FC2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Mark Paid',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.white,
                            fontSize: AppStyles.fontSize12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }
}

class MoreVertDialogueWidget extends StatelessWidget {
  const MoreVertDialogueWidget({
    super.key,
    required this.title,
    this.iconData,
    this.imagePath,
    this.onTap,
  });
  final String title;
  final String? imagePath;
  final Function()? onTap;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          title == 'Remove'
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.kRedColor),
                color: AppColors.kRedColor.withValues(alpha: .1),
              )
              : null,
      padding: EdgeInsets.all(8.sp),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 11.13.w,
          children: [
            iconData != null
                ? Icon(
                  iconData,
                  color: AppColors.kWhiteColor,
                  size: AppStyles.fontSize24,
                )
                : AnyImageView(
                  width: 22.26.w,
                  height: 22.26.h,
                  url: imagePath ?? '',
                  fileType: SourceType.asset,
                ),
            Expanded(
              child: Text(
                title,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white,
                  fontSize: AppStyles.fontSize16,
                  fontWeight: FontWeight.w600,
                  height: 1.33.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
