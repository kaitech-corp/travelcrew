import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/ChatUser.dart';

import '../../../models/chat_module/ChatMessage.dart';
import '../../../services/session_services.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/text_widget.dart';

class MessageWidget extends StatelessWidget {
  final ChatMessage message;
  final ChatUser userModel;
  const MessageWidget({
    super.key,
    required this.message,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:
            message.createdBy == GlobalVariables.loggedInUser.value!.uid
                ? 0
                : 10.w,
        right:
            message.createdBy == GlobalVariables.loggedInUser.value!.uid
                ? 10.w
                : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            message.createdBy == GlobalVariables.loggedInUser.value!.uid
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              if (message.createdBy == GlobalVariables.loggedInUser.value!.uid)
                SizedBox(height: 5),
              if (message.createdBy !=
                  GlobalVariables.loggedInUser.value!.uid) ...{
                Row(
                  spacing: 5.w,
                  children: [
                    AnyImageView(
                      width: 17.87.w,
                      height: 17.87.w,
                      fileType: SourceType.network,
                      url: userModel.profileImage,
                      isCircle: true,
                      containerBackgroundColor: AppColors.kGreyColor.withValues(
                        alpha: .3,
                      ),
                      errorWidget: Icon(Icons.error),
                    ),
                    TextWidget(
                      labelText:
                          message.createdBy ==
                                  GlobalVariables.loggedInUser.value!.uid
                              ? 'You'
                              : userModel.name,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: AppColors.kBlackColor,
                        fontSize: 12,
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
                    message.createdBy == GlobalVariables.loggedInUser.value!.uid
                        ? context.width * 0.67
                        : context.width * 0.8,
                decoration: ShapeDecoration(
                  color:
                      message.createdBy ==
                              GlobalVariables.loggedInUser.value!.uid
                          ? AppColors.kWhiteColor
                          : Color(0xFF151515),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft:
                          message.createdBy !=
                                  GlobalVariables.loggedInUser.value!.uid
                              ? Radius.zero
                              : Radius.circular(16.r),
                      topRight:
                          message.createdBy ==
                                  GlobalVariables.loggedInUser.value!.uid
                              ? Radius.zero
                              : Radius.circular(16.r),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
                child: TextWidget(
                  labelText: message.data,
                  style: AppStyles.labelTextStyle().copyWith(
                    color:
                        message.createdBy ==
                                GlobalVariables.loggedInUser.value!.uid
                            ? AppColors.kBlackColor
                            : Colors.white,
                    fontSize: 12,

                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width:
                    message.createdBy == GlobalVariables.loggedInUser.value!.uid
                        ? context.width * 0.67
                        : context.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (message.createdBy ==
                        GlobalVariables.loggedInUser.value!.uid) ...{
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
                        color: Color(0xFFA1A4C1),
                        fontSize: 10,

                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (message.createdBy == GlobalVariables.loggedInUser.value!.uid) ...{
            SizedBox(width: 5.w),
            AnyImageView(
              width: 42.38.w,
              height: 42.h,
              url: userModel.profileImage,
              fileType: SourceType.network,
              isCircle: true,
              containerBackgroundColor: AppColors.kGreyColor.withValues(
                alpha: .3,
              ),
              errorWidget: Icon(Icons.error),
            ),
          },
        ],
      ),
    );
  }
}
