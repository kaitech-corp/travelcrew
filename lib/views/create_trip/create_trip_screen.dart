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
  bool _restoring = true;

  bool get _isEditing => _routeArguments is TripModel;

  @override
  void initState() {
    super.initState();
    _routeArguments = Get.arguments;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arguments = _routeArguments;
      if (arguments is TripModel) {
        controller.tripModel.value = arguments;
        controller.setAllValuesToEdit();
        if (mounted) setState(() => _restoring = false);
        return;
      }
      try {
        final recovered = await controller.restorePendingTrip();
        if (!mounted) return;
        if (recovered) {
          showCustomSnackBar(
            content:
                arguments is Map<String, dynamic>
                    ? 'Finish the earlier trip save first. The new import was not loaded.'
                    : 'An unfinished trip save was recovered. Tap Finish Trip to retry.',
          );
          setState(() => _restoring = false);
          return;
        }
      } catch (_) {
        if (!mounted) return;
        showCustomSnackBar(
          content:
              'Could not read the unfinished trip save. Reopen this screen to retry recovery.',
        );
        Get.back();
        return;
      }
      if (arguments is Map<String, dynamic>) {
        controller.setFromImport(arguments);
      }
      if (mounted) setState(() => _restoring = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: _isEditing ? l10n.updateTrip : l10n.createTrip,
      maxContentWidth: 720,
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
            if (_restoring) return;
            if (controller.hasPendingCreatedTrip.value) {
              showCustomSnackBar(
                content:
                    'Finish saving this trip before importing another itinerary.',
              );
              return;
            }
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
            Obx(
              () =>
                  controller.hasPendingCreatedTrip.value
                      ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Trip save is unfinished. Tap Finish Trip to check and retry pending expenses.',
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            Obx(
              () => IgnorePointer(
                ignoring: controller.hasPendingCreatedTrip.value,
                child: Opacity(
                  opacity: controller.hasPendingCreatedTrip.value ? 0.55 : 1,
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.r),
        child: Obx(() {
          final pending = controller.hasPendingCreatedTrip.value;
          return CustomElevatedButton(
            isDisabled: _restoring,
            width: Get.width,
            title:
                _isEditing
                    ? l10n.updateTrip
                    : pending
                    ? 'Finish Trip'
                    : l10n.createTrip,
            onPressed: () async {
              if (!_isEditing && pending) {
                await controller.submitTrip();
                return;
              }
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
                if (!_isEditing) {
                  await controller.submitTrip();
                } else {
                  await controller.updateTrip();
                }
              }
            },
            height: 52.02.h,
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    return StepsOne(controller: controller, formKey: _formStep1Key);
  }
}
