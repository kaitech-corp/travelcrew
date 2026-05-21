import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';

class FilterTripsWidget extends StatelessWidget {
  const FilterTripsWidget({super.key, this.onFiltersChanged});
  final Function(List<String> continents)? onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continent',
            style: TextStyle(
              fontSize: AppStyles.fontSize18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              Obx(
                () => continentChip(
                  'Africa',
                  isSelected: _selectedContinents.contains('Africa'),
                  onSelected: (value) => _selectedContinents.add(value),
                ),
              ),
              Obx(
                () => continentChip(
                  'Europe',
                  isSelected: _selectedContinents.contains('Europe'),
                  onSelected: (value) => _selectedContinents.add(value),
                ),
              ),
              Obx(
                () => continentChip(
                  'Asia',
                  isSelected: _selectedContinents.contains('Asia'),
                  onSelected: (value) => _selectedContinents.add(value),
                ),
              ),
              Obx(
                () => continentChip(
                  'N. America',
                  isSelected: _selectedContinents.contains('N. America'),
                  onSelected: (value) => _selectedContinents.add(value),
                ),
              ),
              Obx(
                () => continentChip(
                  'S. America',
                  isSelected: _selectedContinents.contains('S. America'),
                  onSelected: (value) => _selectedContinents.add(value),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: Colors.black.withValues(alpha: .2)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    fixedSize: Size(139.35.w, 51.79.h),
                    backgroundColor: Colors.white.withValues(alpha: .2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Reset',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.white,
                      fontSize: AppStyles.fontSize14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    fixedSize: Size(139.35.w, 51.79.h),
                    backgroundColor: AppColors.kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () {
                    if (_selectedContinents.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please select at least one filter',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    onFiltersChanged?.call(_selectedContinents.toList());
                  },
                  child: Text(
                    'Ok',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.white,
                      fontSize: AppStyles.fontSize14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget continentChip(
  String label, {
  required bool isSelected,
  Function(String value)? onSelected,
}) {
  return GestureDetector(
    onTap: () => onSelected?.call(label),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.kPrimaryColor.withValues(alpha: .1)
                : Colors.white.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(30.r),
        border: isSelected ? Border.all(color: AppColors.kPrimaryColor) : null,
      ),
      child: Text(
        label,
        style: AppStyles.labelTextStyle().copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

RxList<String> _selectedContinents = <String>[].obs;
