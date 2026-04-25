import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import '../../../services/session_services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/text_widget.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    required this.message,
    required this.userModel,
  });
  final ChatMessage message;
  final ChatUser userModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:
            message.createdBy == GlobalVariables.currentUid
                ? 0
                : 10.w,
        right:
            message.createdBy == GlobalVariables.currentUid
                ? 10.w
                : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            message.createdBy == GlobalVariables.currentUid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if (message.createdBy == GlobalVariables.currentUid)
                const SizedBox(height: 5),
              if (message.createdBy !=
                  GlobalVariables.currentUid) ...{
                Row(
                  spacing: 5.w,
                  children: [
                    AnyImageView(
                      width: 17.87.w,
                      height: 17.87.w,
                      url: userModel.profileImage,
                      isCircle: true,
                      containerBackgroundColor: AppColors.kGreyColor.withValues(
                        alpha: .3,
                      ),
                      errorWidget: const Icon(Icons.chat),
                    ),
                    TextWidget(
                      labelText:
                          message.createdBy ==
                                  GlobalVariables.currentUid
                              ? 'You'
                              : userModel.name,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kBlackColor,
                        fontSize: AppStyles.fontSize12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30,
                      ),
                    ),
                  ],
                ),
              },
              Container(
                padding: const EdgeInsets.all(16),
                width:
                    message.createdBy == GlobalVariables.currentUid
                        ? context.width * 0.67
                        : context.width * 0.8,
                decoration: ShapeDecoration(
                  color:
                      message.createdBy ==
                              GlobalVariables.currentUid
                          ? AppColors.kWhiteColor
                          : AppColors.kLightGreyColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          message.createdBy !=
                                  GlobalVariables.currentUid
                              ? Radius.zero
                              : Radius.circular(16.r),
                      topRight:
                          message.createdBy ==
                                  GlobalVariables.currentUid
                              ? Radius.zero
                              : Radius.circular(16.r),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                  ),
                ),
                child: TextWidget(
                  labelText: message.data,
                  style: AppStyles.labelTextStyle().copyWith(
                    color: AppColors.kBlackColor,
                    fontSize: AppStyles.fontSize12,

                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width:
                    message.createdBy == GlobalVariables.currentUid
                        ? context.width * 0.67
                        : context.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (message.createdBy ==
                        GlobalVariables.currentUid) ...{
                      ImageIcon(
                        AssetImage(AppImages.kMessageReadIcon),
                        color: AppColors.kPrimaryColor,
                        size: 20.h,
                      ),
                    } else
                      ...{},
                    TextWidget(
                      labelText: DateFormat(
                        'hh:mm a',
                      ).format(message.createdAt.toDate()),
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFFA1A4C1),
                        fontSize: AppStyles.fontSize12,

                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (message.createdBy == GlobalVariables.currentUid) ...{
            SizedBox(width: 5.w),
            AnyImageView(
              width: 42.38.w,
              height: 42.h,
              url: userModel.profileImage,
              isCircle: true,
              containerBackgroundColor: AppColors.kGreyColor.withValues(
                alpha: .3,
              ),
              errorWidget: const Icon(Icons.error),
            ),
          },
        ],
      ),
    );
  }
}
