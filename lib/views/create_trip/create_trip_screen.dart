import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/create_trip/components/steps_five.dart';
import 'package:travel_crew/views/create_trip/components/steps_one.dart';
import 'package:travel_crew/views/create_trip/components/steps_six.dart';
import 'package:travel_crew/views/create_trip/components/steps_two.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';

import '../../models/trip_model.dart';
import '../custom_widgets/custom_scaffold.dart';
import 'components/steps_four.dart';
import 'components/steps_seven.dart';
import 'components/steps_three.dart';

class CreateTripScreen extends GetView<CreateTripController> {
  CreateTripScreen({super.key});
  bool isFirstTime = true;
  @override
  Widget build(BuildContext context) {
    if (Get.arguments is TripModel && isFirstTime) {
      Future.microtask(() {
        controller.tripModel.value = Get.arguments as TripModel;
        controller.setAllValuesToEdit();
      });
    }
    return CustomScaffold(
      screenName: '${Get.arguments is! TripModel ? 'Create' : 'Update'} Trip',
      isBackIcon: true,
      onWillPop: () {
        GlobalVariables.showLoader.value = false;
        controller.previousStep();
      },
      // onBackPressed: controller.previousStep,
      scaffoldKey: controller.scaffoldKey,
      onBackButtonPressed: () => controller.previousStep(),
      className: runtimeType.toString(),
      centerTitle: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 30.h),
            SizedBox(height: 10.h),
            Obx(() => _buildCurrentStep()),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomElevatedButton(
              width: Get.width * 0.43,
              title:
                  '${Get.arguments is! TripModel ? 'Create' : 'Update'} Trip',
              onPressed: () {
                if (controller.formStep1.currentState!.validate()) {
                  if (controller.selectedPlaceId.isEmpty) {
                    showCustomSnackBar(content: 'Please select a location');
                    return;
                  }
                  if (controller.startDate.value == null ||
                      controller.endDate.value == null) {
                    showCustomSnackBar(content: 'Please select a date');
                    return;
                  }
                  if (controller.selectedImages.isEmpty) {
                    showCustomSnackBar(
                      content: 'Please select at least one image',
                    );

                    return;
                  }
                  if (Get.arguments is! TripModel) {
                    controller.submitTrip();
                  } else {
                    controller.updateTrip();
                  }
                }
              },
              height: 52.02.h,
            ),
            CustomElevatedButton(
              width: Get.width * 0.43,
              title: 'Continue',
              onPressed: controller.nextStep,
              height: 52.02.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (controller.currentStep.value) {
      case 1:
        return StepsOne(controller: controller);
      case 2:
        return StepsTwo(controller: controller);
      case 3:
        return StepsThree(controller: controller);
      case 4:
        return StepsFour(controller: controller);
      case 5:
        return StepsFive(controller: controller);
      case 6:
        return StepsSix(controller: controller);
      case 7:
        return StepsSeven(controller: controller);
      default:
        return StepsOne(controller: controller);
    }
  }
}
