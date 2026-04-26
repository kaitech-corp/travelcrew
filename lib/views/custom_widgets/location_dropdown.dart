import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/search_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/common_code.dart';

import '../../utils/app_styles.dart';

class LocationDropdownWidget extends StatefulWidget {
  const LocationDropdownWidget({
    required this.selectedText,
    super.key,
    this.textInputAction = TextInputAction.next,
    this.hintText = 'Search location',
    this.suffixIconConstraints,
    this.onTap,
    this.items = const [],
    this.validator,
    this.onChanged,
    required this.textEditingController,
    required this.focusNode,
    this.suffixIcon,
  });
  final List<SearchModel> items;
  final String selectedText;
  final TextEditingController textEditingController;
  final Widget? suffixIcon;
  final Function(String placeId, SearchModel searchText)? onTap;
  final TextInputAction textInputAction;
  final BoxConstraints? suffixIconConstraints;
  final String hintText;
  final String? Function(String?)? validator;
  final FocusNode focusNode;
  final Function(String? value)? onChanged;

  @override
  State<LocationDropdownWidget> createState() => _LocationDropdownWidgetState();
}

class _LocationDropdownWidgetState extends State<LocationDropdownWidget> {
  bool showDropdown = false;
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(checkIfFocus);
  }

  void checkIfFocus() {
    if (widget.focusNode.hasFocus) {
      GlobalVariables.showDropdown.value = true;
    } else {
      GlobalVariables.showDropdown.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kGreyColor.withAlpha(26),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            textInputAction: widget.textInputAction,
            textCapitalization: TextCapitalization.sentences,
            validator: widget.validator,
            onTapUpOutside: (event) => CommonCode().removeTextFieldFocus(),

            onEditingComplete:
                () => widget.onChanged?.call(widget.textEditingController.text),
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              suffixIconConstraints: widget.suffixIconConstraints,
              suffixIcon: widget.suffixIcon,
              fillColor:
                  GlobalVariables.showDropdown.isTrue
                      ? AppColors.kPrimaryColor.withAlpha(26)
                      : AppColors.kLightGreyColor,
              filled: true,
              hintStyle: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize16,
                color: Colors.grey[600],
              ),

              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 15.h,
              ),
              prefixIconConstraints: BoxConstraints(maxWidth: 60.w),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: const BorderSide(color: AppColors.kPrimaryColor),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 7.w),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20.r,
                  child: Icon(
                    Icons.search,
                    color:
                        GlobalVariables.showDropdown.isTrue
                            ? Colors.blue
                            : AppColors.kBlackColor,
                    size: AppStyles.fontSize24,
                  ),
                ),
              ),
              hintText: widget.hintText,
            ),
            controller:
                widget.textEditingController
                  ..selection = TextSelection.collapsed(
                    offset: widget.selectedText.length,
                  ),
          ),

          // Dropdown List
          Obx(
            () =>
                GlobalVariables.showDropdown.isFalse
                    ? const SizedBox.shrink()
                    : Padding(
                      padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: context.height * 0.4,
                        ),

                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.items.length,
                          itemBuilder: (context, index) {
                            final isSelected =
                                widget.selectedText ==
                                widget.items[index].searchText;
                            return GestureDetector(
                              onTap: () {
                                widget.textEditingController.text =
                                    widget.items[index].searchText;
                                widget.onTap?.call(
                                  widget.items[index].placeId ?? '',
                                  widget.items[index],
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue.withAlpha(26)
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color:
                                          isSelected
                                              ? Colors.black
                                              : Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        widget.items[index].searchText,
                                        style: AppStyles.labelTextStyle()
                                            .copyWith(
                                              fontSize: AppStyles.fontSize16,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  isSelected
                                                      ? Colors.black
                                                      : Colors.grey.shade600,
                                            ),
                                      ),
                                    ),
                                    if (widget.items[index].views != null)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                        ),
                                        child: Text(
                                          '${widget.items[index].views} views',
                                          style: AppStyles.labelTextStyle()
                                              .copyWith(
                                                fontSize: AppStyles.fontSize12,
                                                color:
                                                    isSelected
                                                        ? Colors.blue
                                                        : Colors.grey.shade700,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  final OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30.r),
    borderSide: BorderSide(color: AppColors.kLightGreyColor, width: .5),
  );
}
