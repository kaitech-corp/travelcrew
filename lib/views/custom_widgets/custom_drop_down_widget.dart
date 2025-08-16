import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class SimpleDropdown<T> extends StatefulWidget {
  const SimpleDropdown({
    super.key,
    required this.items,
    this.itemBuilder,
    required this.onChanged,
    this.value,
    this.hintText = 'Select Members',
  });
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final Widget Function(T)? itemBuilder;
  final String hintText;
  @override
  _SimpleDropdownState<T> createState() => _SimpleDropdownState<T>();
}

class _SimpleDropdownState<T> extends State<SimpleDropdown<T>> {
  bool _isDropdownOpen = false;
  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _selectItem(T item) {
    widget.onChanged(item);
    setState(() {
      value = item;
      _isDropdownOpen = false;
    });
  }

  T? value;
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
          GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value != null ? value.toString() : widget.hintText,
                    style:
                        value != null
                            ? AppStyles.labelTextStyle().copyWith(
                              color: Colors.black87,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            )
                            : AppStyles.labelTextStyle().copyWith(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                  ),
                  Icon(
                    !_isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          if (_isDropdownOpen) _buildDropdownList(),
        ],
      ),
    );
  }

  Widget _buildDropdownList() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.height * 0.4),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return InkWell(
            onTap: () => _selectItem(item),
            child:
                widget.itemBuilder != null
                    ? widget.itemBuilder!(item)
                    : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        item.toString(),
                        style: AppStyles.labelTextStyle().copyWith(
                          color: Colors.black87,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
