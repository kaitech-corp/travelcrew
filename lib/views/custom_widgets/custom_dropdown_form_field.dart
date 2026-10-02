import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../utils/app_styles.dart';

class CustomDropdownFormField extends StatefulWidget {
  const CustomDropdownFormField({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.hintText = 'Select Item',
  });
  final String title;
  final List<String> items;
  final String selectedItem;
  final Function(String) onItemSelected;
  final String hintText;
  @override
  State<CustomDropdownFormField> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  final RxBool _isDropdownOpen = false.obs;
  late String _selectedItem;
  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  void _toggleDropdown() {
    _isDropdownOpen.value = !_isDropdownOpen.value;
  }

  void _selectItem(String item) {
    setState(() {
      _selectedItem = item;
    });
    widget.onItemSelected(item);
    _isDropdownOpen.value = false; // Close dropdown after selection
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedItem.isEmpty ? widget.hintText : widget.title,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.black87,
                      fontSize: AppStyles.fontSize16,

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    _isDropdownOpen.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Dropdown content
        Obx(
          () => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height:
                _isDropdownOpen.value
                    ? min(widget.items.length * 50.h, 200.h)
                    : 0,
            margin: EdgeInsets.only(top: _isDropdownOpen.value ? 8.h : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow:
                  _isDropdownOpen.value
                      ? [
                        BoxShadow(
                          color: Colors.black.withAlpha(26),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : [],
            ),
            child:
                _isDropdownOpen.value
                    ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isSelected = _selectedItem == item;
                        return InkWell(
                          onTap: () => _selectItem(item),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: AppStyles.fontSize16,
                                    color: Colors.blue,
                                  ),
                                Text(
                                  item,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: Colors.black87,
                                    fontSize: AppStyles.fontSize14,

                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  double min(double a, double b) {
    return a < b ? a : b;
  }
}
