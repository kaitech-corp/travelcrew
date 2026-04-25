import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/search_model.dart';
import 'package:travel_crew/utils/app_styles.dart';

import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/location_dropdown.dart';
import '../controller/create_trip_controller.dart';

class StepsTwo extends StatelessWidget {
  const StepsTwo({super.key, required this.controller});
  final CreateTripController controller;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Airline Name',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,

              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => LocationDropdownWidget(
              selectedText: controller.searchText.value,
              onChanged: (value) {
                controller.fetchAeroPlanes(value);
              },
              items:
                  controller.airlineList.map((e) {
                    return SearchModel(searchText: e.airline?.name ?? '');
                  }).toList(),
              // validator:
              //     (p0) =>
              //         p0?.isBlank == true ? 'Please select an airline' : null,
              textEditingController: controller.airLineNameController,
              focusNode: FocusNode(),
            ),
          ),
          SizedBox(height: 27.h),
          Text(
            'Flight Number',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: AppStyles.fontSize20,

              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            // validator:
            //     (p0) =>
            //         p0?.isBlank == true ? 'Please enter flight number' : null,
            hintText: '23434',
            controller: controller.flightNumberController,
            focusNode: controller.flightNumberFocusNode,
          ),
          SizedBox(height: 27.h),
        ],
      ),
    );
  }
}
