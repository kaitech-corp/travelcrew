import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/geo_services.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import '../../../../../models/search_model.dart';

class SpecificTripViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> addActivityScaffoldKey =
      GlobalKey<ScaffoldState>();

  Rxn<DateTime> activityStartTime = Rxn<DateTime>();
  Rxn<DateTime> activityEndTime = Rxn<DateTime>();
  RxBool isLiked = false.obs;
  Rxn<TripModel> tripModel = Rxn<TripModel>();
  RxBool isLocked = true.obs;
  final List<String> tripTabs = [
    'Transport',
    'Expense',
    'Lodging',
    'Activities',
  ];
  final selectedTabIndex = 0.obs;

  TextEditingController activityNoteController = TextEditingController(),
      activityNameController = TextEditingController(),
      locationController = TextEditingController();

  FocusNode activityNameFocusNode = FocusNode(),
      activityNoteFocusNode = FocusNode(),
      locationFocusNode = FocusNode();

  RxString searchText = ''.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> removeTrip() async {
    GlobalVariables.showLoader.value = true;
    try {
      await FirebaseTripService.deleteTrip(tripModel.value!.id).then((value) {
        if (value) {
          removeTripOverAll(tripModel.value!);
          Get.back();
          showCustomSnackBar(content: 'Trip removed successfully');
        } else {
          showCustomSnackBar(content: 'Failed to remove trip');
        }
      });
    } catch (e) {}
    GlobalVariables.showLoader.value = false;
  }

  Future<void> likeActivity({required String activityId, bool isLiked = false}) async {
    try {
      await FirebaseTripService.likeActivity(
        activityId: activityId,
        isLiked: isLiked,
        userId: GlobalVariables.loggedInUser.value?.uid ?? '',
      ).then((value) {
        if (value) {
          if (isLiked) {
            tripModel.value?.activities
                ?.firstWhere((element) => element.id == activityId)
                .likedBy
                .remove(GlobalVariables.loggedInUser.value!.uid);
            tripModel.value?.activities
                ?.firstWhere((element) => element.id == activityId)
                .likesCount--;
          } else {
            tripModel.value?.activities
                ?.firstWhere((element) => element.id == activityId)
                .likedBy
                .add(GlobalVariables.loggedInUser.value!.uid);
            tripModel.value?.activities
                ?.firstWhere((element) => element.id == activityId)
                .likesCount++;
          }
        } else {
          showCustomSnackBar(content: 'Failed to like activity');
        }
        tripModel.refresh();
        updateTripOverAll(tripModel.value!);
      });
    } catch (e) {}
  }

  Future<void> addActivity() async {
    try {
      if (activityEndTime.value == null || activityStartTime.value == null) {
        showCustomSnackBar(
          content: 'Please select start and end date and time',
        );
        return;
      }
      GlobalVariables.showLoader.value = true;
      final ActivityModel activityModel = ActivityModel(
        id: Get.arguments['toAdd'] ? const Uuid().v6() : Get.arguments['activity'].id as String,
        tripId: Get.arguments['tripId'] as String,
        title: activityNameController.text,
        location: locationController.text,
        startDateTime: activityStartTime.value ?? DateTime.now(),
        endDateTime: activityEndTime.value ?? DateTime.now(),
        description: activityNoteController.text,
        likedBy:
            Get.arguments['toAdd'] ? [] : Get.arguments['activity'].likedBy as List<String>,
        likesCount:
            Get.arguments['toAdd'] ? 0 : Get.arguments['activity'].likesCount as int,
      );
      if (Get.arguments['toAdd']) {
        await FirebaseTripService.addActivity(activity: activityModel).then((
          value,
        ) {
          GlobalVariables.showLoader.value = false;
          if (value) {
            Get.arguments['onAdded']?.call(activityModel);
            Get.back();
            showCustomSnackBar(content: 'Activity added successfully');
          } else {
            showCustomSnackBar(content: 'Failed to add activity');
          }
        });
      } else {
        await FirebaseTripService.updateActivity(activity: activityModel).then((
          value,
        ) {
          GlobalVariables.showLoader.value = false;
          if (value) {
            Get.arguments['onAdded']?.call(activityModel);
            Get.back();
            showCustomSnackBar(content: 'Activity updated successfully');
          } else {
            showCustomSnackBar(content: 'Failed to update activity');
          }
        });
      }
    } catch (e) {
      GlobalVariables.showLoader.value = false;
    }
  }

  RxList<SearchModel> locations = <SearchModel>[].obs;
  Future<void> fetchLocations(String value) async {
    try {
      final res = await GeoServices.fetchSuggestions(value);
      locations.value =
          res
              .map(
                (v) => SearchModel(
                  searchText: v['description'] ?? '',
                  placeId: v['place_id'],
                ),
              )
              .toList();
    } catch (e) {}
  }

  Future<bool> doitFavourite(String? id, {required bool isFavourites}) async {
    try {
      GlobalVariables.addingToFavourites.value = id ?? '';
      // await AuthService.addToFavourites(
      //   id: id ?? '',
      //   isFavourites: isFavourites,
      // ).then((value) {});
    } catch (e) {}
    GlobalVariables.addingToFavourites.value = '';
    return isLiked.value;
  }
}
