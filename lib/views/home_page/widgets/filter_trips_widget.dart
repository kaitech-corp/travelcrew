import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_field.dart';

class FilterTripsWidget extends StatelessWidget {
  const FilterTripsWidget({super.key, this.onPriceRangeChanged});
  final Function(double minimum, double maximum, List<String> continents)?
  onPriceRangeChanged;

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
            'Price Range',
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.white,
                        fontSize: 14.57,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      controller: _minPriceController,
                      prefixIcon: Icon(
                        Icons.attach_money,
                        size: 22.sp,
                        color: AppColors.kBlackColor.withValues(alpha: .5),
                      ),
                      prefixIconConstraints: BoxConstraints(maxWidth: 30.w),
                      hintText: '1,500',
                      fillColor: Colors.white.withValues(alpha: .2),
                      height: 50.h,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 30.h),
                child: Text(
                  '-',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black.withValues(alpha: .5),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maximum',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.white,
                        fontSize: 14.57,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    CustomTextField(
                      controller: _maxPriceController,
                      hintText: '2,500',
                      fillColor: Colors.white.withValues(alpha: .2),
                      prefixIcon: Icon(
                        Icons.attach_money,
                        size: 22.sp,
                        color: AppColors.kBlackColor.withValues(alpha: .5),
                      ),
                      prefixIconConstraints: BoxConstraints(maxWidth: 30.w),
                      height: 50.h,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          const Text(
            'Continent',
            style: TextStyle(
              fontSize: 18,
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
                      fontSize: 14.57,
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
                    if (_selectedContinents.isEmpty &&
                        _minPriceController.text.isEmpty &&
                        _maxPriceController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please select at least one filter',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    final double minPrice =
                        double.tryParse(_minPriceController.text) ?? 0;
                    final double maxPrice =
                        double.tryParse(_maxPriceController.text) ?? 10000000;
                    onPriceRangeChanged?.call(
                      minPrice,
                      maxPrice,
                      _selectedContinents.toList(),
                    );
                  },
                  child: Text(
                    'Ok',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.white,
                      fontSize: 14.57,
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

final TextEditingController _minPriceController = TextEditingController();
final TextEditingController _maxPriceController = TextEditingController();
RxList<String> _selectedContinents = <String>[].obs;
