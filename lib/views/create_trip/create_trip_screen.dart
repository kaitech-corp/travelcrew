import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/create_trip/components/steps_one.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';

import '../../models/trip_model.dart';
import '../custom_widgets/custom_scaffold.dart';

class CreateTripScreen extends GetView<CreateTripController> {
  CreateTripScreen({super.key});
  bool isFirstTime = true;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (Get.arguments is TripModel && isFirstTime) {
      Future.microtask(() {
        controller.tripModel.value = Get.arguments as TripModel;
        controller.setAllValuesToEdit();
      });
    } else if (Get.arguments is Map<String, dynamic> && isFirstTime) {
      Future.microtask(() {
        controller.setFromImport(Get.arguments as Map<String, dynamic>);
      });
    }
    return CustomScaffold(
      screenName: Get.arguments is TripModel ? l10n.updateTrip : l10n.createTrip,
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
            _buildCurrentStep(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.r),
        child: CustomElevatedButton(
          width: Get.width,
          title: Get.arguments is TripModel ? l10n.updateTrip : l10n.createTrip,
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
      ),
    );
  }

  Widget _buildCurrentStep() {
    return StepsOne(controller: controller);
  }
}
