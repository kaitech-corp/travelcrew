import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';

class SingleDatePickerScreen extends StatefulWidget {

  const SingleDatePickerScreen({
    super.key,
    this.onDateSelected,
    this.focusedDay,
    required this.onDateChanged,
    this.initialDate,
    this.lastDate,
  });
  final DateTime? focusedDay;
  final DateTime? initialDate;
  final DateTime? lastDate;
  final Function(DateTime? selectedDate)? onDateSelected;
  final Function(DateTime? selectedDate) onDateChanged;

  @override
  _SingleDatePickerScreenState createState() => _SingleDatePickerScreenState();
}

class _SingleDatePickerScreenState extends State<SingleDatePickerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _selectedDay = widget.focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: AppStyles.fontSize20,
                  ),
                  onPressed: () {
                    final DateTime currentTime = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                    if (currentTime.isAfter(
                          widget.initialDate ??
                              DateTime.utc(DateTime.now().year - 6),
                        ) ||
                        (currentTime.month == widget.initialDate!.month &&
                            currentTime.year == widget.initialDate!.year)) {
                      if (currentTime.month == widget.initialDate!.month &&
                          currentTime.year == widget.initialDate!.year) {
                        setState(() {
                          _focusedDay = widget.focusedDay!;
                        });
                      } else {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                          );
                        });
                      }
                    }
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style:  TextStyle(
                    color: Colors.white,
                    fontSize: AppStyles.fontSize18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: AppStyles.fontSize20,
                  ),
                  onPressed: () {
                    if (DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                    ).isBefore(
                      widget.lastDate ??
                          DateTime.utc(DateTime.now().year + 6, 12, 31),
                    )) {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month + 1,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 3.0),
          const Divider(color: AppColors.kGreyTextColor),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TableCalendar(
              firstDay:
                  widget.initialDate ??
                  DateTime.utc(DateTime.now().year - 6),
              lastDay:
                  widget.lastDate ??
                  DateTime.utc(DateTime.now().year + 6, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                widget.onDateChanged.call(selectedDay);
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerVisible: false,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white,
                ),
                weekendTextStyle: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white,
                ),
                outsideTextStyle: AppStyles.labelTextStyle().copyWith(
                  color: Colors.grey,
                ),
                cellMargin: const EdgeInsets.all(1.5),
                defaultDecoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                outsideDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                weekendDecoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(
              color: AppColors.kBlackColor.withOpacity(0.5),
              thickness: .61,
            ),
          ),
          // Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(143.95.w, 51.59.h),
                    backgroundColor: Colors.grey[600],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppStyles.labelTextStyle().copyWith(
                      color: Colors.white,
                      fontSize: AppStyles.fontSize14,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onDateSelected?.call(_selectedDay);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    fixedSize: Size(143.95.w, 51.59.h),
                    backgroundColor: AppColors.kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                  ),
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
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
