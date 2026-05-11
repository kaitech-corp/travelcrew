import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/create_trip/components/steps_one.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';

import '../../models/trip_model.dart';
import '../custom_widgets/custom_scaffold.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final CreateTripController controller = Get.find<CreateTripController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formStep1Key = GlobalKey<FormState>();
  late final Object? _routeArguments;

  bool get _isEditing => _routeArguments is TripModel;

  @override
  void initState() {
    super.initState();
    _routeArguments = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = _routeArguments;
      if (arguments is TripModel) {
        controller.tripModel.value = arguments;
        controller.setAllValuesToEdit();
      } else if (arguments is Map<String, dynamic>) {
        controller.setFromImport(arguments);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: _isEditing ? l10n.updateTrip : l10n.createTrip,
      onWillPop: () {
        GlobalVariables.showLoader.value = false;
        controller.previousStep();
      },
      // onBackPressed: controller.previousStep,
      scaffoldKey: _scaffoldKey,
      onBackButtonPressed: () => controller.previousStep(),
      className: widget.runtimeType.toString(),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () async {
            final importedData = await Get.toNamed(
              kImportTripScreenRoute,
              arguments: {'returnToCreate': true},
            );
            if (importedData is Map<String, dynamic>) {
              controller.setFromImport(importedData);
            }
          },
          child: Padding(
            padding: EdgeInsets.only(right: 24.w),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 22,
              color: Colors.black87,
            ),
          ),
        ),
      ],
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
          title: _isEditing ? l10n.updateTrip : l10n.createTrip,
          onPressed: () async {
            if (_formStep1Key.currentState!.validate()) {
              if (controller.selectedPlaceId.isEmpty) {
                showCustomSnackBar(content: 'Please select a location');
                return;
              }
              if (controller.startDate.value == null ||
                  controller.endDate.value == null) {
                showCustomSnackBar(content: 'Please select a date');
                return;
              }
              await controller.usePlacePhotoAsCoverIfNeeded();
              if (controller.selectedImages.isEmpty) {
                showCustomSnackBar(content: 'Please select at least one image');
                return;
              }
              if (!_isEditing) {
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
    return StepsOne(controller: controller, formKey: _formStep1Key);
  }
}
