import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/text_widget.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.userModel,
  });

  final ChatMessage message;
  final ChatUser userModel;

  bool get _isMine => message.createdBy == GlobalVariables.currentUid;

  @override
  Widget build(BuildContext context) {
    final bubbleWidth = context.width * (_isMine ? 0.72 : 0.78);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment:
            _isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isMine) ...[
            _Avatar(url: userModel.profileImage),
            SizedBox(width: 10.w),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bubbleWidth),
              child: Column(
                crossAxisAlignment:
                    _isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: _isMine ? 0 : 2.w,
                      right: _isMine ? 2.w : 0,
                      bottom: 6.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          _isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (_isMine) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kLightBlueColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'You',
                              style: AppStyles.labelTextStyle().copyWith(
                                color: AppColors.kPrimaryColor,
                                fontSize: AppStyles.fontSize12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        TextWidget(
                          labelText: _displayName,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: AppColors.kBlackColor,
                            fontSize: AppStyles.fontSize13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!_isMine) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kLightBlueColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Member',
                              style: AppStyles.labelTextStyle().copyWith(
                                color: AppColors.kPrimaryColor,
                                fontSize: AppStyles.fontSize12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isMine
                              ? AppColors.kPrimaryColor
                              : AppColors.kWhiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(_isMine ? 16.r : 6.r),
                        topRight: Radius.circular(_isMine ? 6.r : 16.r),
                        bottomLeft: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                      ),
                      border: Border.all(
                        color: _isMine
                            ? AppColors.kPrimaryColor.withValues(alpha: .12)
                            : AppColors.kLightGreyColor,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextWidget(
                      labelText: message.data,
                      style: AppStyles.labelTextStyle().copyWith(
                        color:
                            _isMine
                                ? AppColors.kWhiteColor
                                : AppColors.kBlackColor,
                        fontSize: AppStyles.fontSize14,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        _isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (_isMine) ...[
                        ImageIcon(
                          AssetImage(AppImages.kMessageReadIcon),
                          color: AppColors.kPrimaryColor,
                          size: 16.h,
                        ),
                        SizedBox(width: 4.w),
                      ],
                      TextWidget(
                        labelText: DateFormat('hh:mm a').format(
                          message.createdAt.toDate(),
                        ),
                        style: AppStyles.labelTextStyle().copyWith(
                          color: AppColors.kGreyyColor,
                          fontSize: AppStyles.fontSize12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isMine) ...[
            SizedBox(width: 10.w),
            _Avatar(url: userModel.profileImage),
          ],
        ],
      ),
    );
  }

  String get _displayName {
    if (userModel.name.isNotEmpty) return userModel.name;
    if (_isMine) {
      return GlobalVariables.userProfile.value?.displayName ??
          GlobalVariables.loggedInUser.value?.displayName ??
          'You';
    }
    return 'Member';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AnyImageView(
      width: 38.w,
      height: 38.w,
      url: url,
      isCircle: true,
      containerBackgroundColor: AppColors.kGreyColor.withValues(alpha: .15),
      errorWidget: const Icon(Icons.person),
    );
  }
}
