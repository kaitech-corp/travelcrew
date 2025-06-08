import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';

class DateRangePickerScreen extends StatefulWidget {
  final DateTime? focusedDay;
  final DateTime? rangeStart;
  final DateTime? initialDate;
  final DateTime? lastDate;
  final DateTime? rangeEnd;
  final Function(DateTime? startDate, DateTime? endDate)? onRangeSelected;
  final Function(DateTime? selectedDate, DateTime? endDate) onRangeChanged;
  const DateRangePickerScreen({
    super.key,
    this.onRangeSelected,
    required this.onRangeChanged,
    this.focusedDay,
    this.initialDate,
    this.lastDate,
    this.rangeStart,
    this.rangeEnd,
  });

  @override
  _DateRangePickerScreenState createState() => _DateRangePickerScreenState();
}

class _DateRangePickerScreenState extends State<DateRangePickerScreen> {
  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay ?? DateTime.now();
    _rangeStart = widget.rangeStart;
    _rangeEnd = widget.rangeEnd;
  }

  DateTime _focusedDay = DateTime.now(); // Focus on July 2024
  DateTime? _rangeStart = DateTime.now(); // Start of the range
  DateTime? _rangeEnd = DateTime(DateTime.now().year + 20); // End of the range

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: AppColors.kPrimaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey],
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with month/year and navigation arrows
          Padding(
            padding: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    DateTime currentTime = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                    );
                    if (currentTime.isAfter(
                          widget.initialDate ??
                              DateTime.utc(DateTime.now().year - 6, 1, 1),
                        ) ||
                        (currentTime.month == widget.initialDate!.month &&
                            currentTime.year == widget.initialDate!.year)) {
                      if ((currentTime.month == widget.initialDate!.month &&
                          currentTime.year == widget.initialDate!.year)) {
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20.sp,
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
          Divider(color: AppColors.kGreyTextColor),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TableCalendar(
              firstDay:
                  widget.initialDate ??
                  DateTime.utc(DateTime.now().year - 6, 1, 1),
              lastDay:
                  widget.lastDate ??
                  DateTime.utc(DateTime.now().year + 6, 12, 31),
              focusedDay: _focusedDay,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20.sp,
                ),
                rightChevronIcon: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              calendarFormat: CalendarFormat.month,
              headerVisible: false, // Hide default header
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

                cellMargin: EdgeInsets.all(1.5),
                defaultDecoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .2),
                  shape: BoxShape.circle,
                ),
                outsideDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withValues(alpha: .2)),
                ),
                weekendDecoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .2),
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
                rangeStartDecoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.blue, width: 1),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.blue, width: 1),
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: Colors.teal.withValues(alpha: 0.3),
                withinRangeTextStyle: const TextStyle(color: Colors.white),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  if (_rangeStart == null || _rangeEnd != null) {
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                  } else if (selectedDay.isAfter(_rangeStart!)) {
                    _rangeEnd = selectedDay;
                  } else {
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                  }
                  _focusedDay = focusedDay;
                });
                if (_rangeStart != null && _rangeEnd != null) {
                  widget.onRangeChanged.call(_rangeStart!, _rangeEnd!);
                }
                if (_rangeStart != null && _rangeEnd == null) {
                  widget.onRangeChanged.call(_rangeStart!, _rangeStart!);
                }
                if (_rangeStart == null && _rangeEnd != null) {
                  widget.onRangeChanged.call(_rangeEnd!, _rangeEnd!);
                }
                if (_rangeStart == null && _rangeEnd == null) {
                  widget.onRangeChanged.call(null, null);
                }
              },
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(
              color: AppColors.kBlackColor.withValues(alpha: .5),
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
                    // Handle cancel action
                    widget.onRangeSelected?.call(
                      widget.rangeStart,
                      widget.rangeEnd,
                    );
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
                      fontSize: 14.49,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle ok action
                    if (_rangeStart != null && _rangeEnd != null) {
                      widget.onRangeSelected?.call(_rangeStart, _rangeEnd);
                    } else if (_rangeStart != null) {
                      widget.onRangeSelected?.call(_rangeStart, _rangeStart);
                    } else if (_rangeEnd != null) {
                      widget.onRangeSelected?.call(_rangeEnd, _rangeEnd);
                    } else {
                      widget.onRangeSelected?.call(null, null);
                    }
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
                      fontSize: 14.49,
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
