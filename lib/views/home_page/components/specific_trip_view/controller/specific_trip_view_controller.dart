import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/expense_service.dart';
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

  final ScrollController scrollController = ScrollController();
  final Map<String, GlobalKey> sectionKeys = {
    'Overview': GlobalKey(),
    'Crew': GlobalKey(),
    'Activities': GlobalKey(),
    'Flights': GlobalKey(),
    'Lodging': GlobalKey(),
    'Transport': GlobalKey(),
    'Expenses': GlobalKey(),
  };

  List<Settlement> get optimalSettlements => tripModel.value != null
      ? ExpenseService().computeOptimalSettlements(tripModel.value!)
      : [];

  Future<void> markSettlementPaid(String fromUserId) async {
    try {
      GlobalVariables.showLoader.value = true;
      for (final expense in tripModel.value?.expenses ?? []) {
        if (expense.createdBy != fromUserId &&
            !expense.paidByUsers.contains(fromUserId)) {
          expense.paidByUsers.add(fromUserId);
          await FirebaseTripService.updateExpense(expense);
        }
      }
      tripModel.refresh();
      showCustomSnackBar(content: 'Settlement marked as paid');
    } catch (e) {
      showCustomSnackBar(content: 'Failed to mark settlement');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  void scrollToSection(String section) {
    final key = sectionKeys[section];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

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
                .remove(GlobalVariables.currentUid);
            tripModel.value?.activities
                ?.firstWhere((element) => element.id == activityId)
                .likesCount--;
          } else {
            tripModel.value?.activities
                ?.firstWhere((element) => element.id == activityId)
                .likedBy
                .add(GlobalVariables.currentUid);
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

  Future<void> joinTrip() async {
    try {
      if (tripModel.value == null) {
        showCustomSnackBar(content: 'Trip not found');
        return;
      }

      final currentUserId = GlobalVariables.loggedInUser.value?.uid;
      if (currentUserId == null) {
        showCustomSnackBar(content: 'Please log in to join this trip');
        return;
      }

      // Check if user is already in the trip
      if (tripModel.value!.joinedUsers?.contains(currentUserId) == true) {
        showCustomSnackBar(content: 'You are already part of this trip');
        return;
      }

      GlobalVariables.showLoader.value = true;
      
      final success = await FirebaseTripService.joinTrip(
        tripId: tripModel.value!.id,
        userId: currentUserId,
      );

      if (success) {
        // Update local trip model
        tripModel.value!.joinedUsers ??= [];
        tripModel.value!.joinedUsers!.add(currentUserId);
        
        // Refresh the joined users list
        if (tripModel.value!.joinedUsers!.isNotEmpty) {
          tripModel.value!.joindUsersList = await AuthService.getTripUsers(
            userIds: tripModel.value!.joinedUsers!,
          );
        }
        
        tripModel.refresh();
        updateTripOverAll(tripModel.value!);
        
        showCustomSnackBar(content: 'Successfully joined the trip!');
      } else {
        showCustomSnackBar(content: 'Failed to join trip. Please try again.');
      }
    } catch (e) {
      showCustomSnackBar(content: 'An error occurred while joining the trip');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> inviteToTrip() async {
    try {
      if (tripModel.value == null) {
        showCustomSnackBar(content: 'Trip not found');
        return;
      }

      // Navigate to invite screen or show invite dialog
      // For now, we'll show a simple dialog to get email
      Get.dialog(
        AlertDialog(
          title: const Text('Invite to Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter email address to invite:'),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(),
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (email) {
                  if (email.isNotEmpty && email.contains('@')) {
                    _sendInvite(email);
                    Get.back();
                  } else {
                    showCustomSnackBar(content: 'Please enter a valid email address');
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get email from text field and send invite
                Get.back();
                showCustomSnackBar(content: 'Invite functionality will be implemented');
              },
              child: const Text('Send Invite'),
            ),
          ],
        ),
      );
    } catch (e) {
      showCustomSnackBar(content: 'An error occurred while inviting to trip');
    }
  }

  Future<void> _sendInvite(String email) async {
    try {
      GlobalVariables.showLoader.value = true;
      
      // Add email to invited users list
      tripModel.value!.invitedUsers ??= [];
      if (!tripModel.value!.invitedUsers!.contains(email)) {
        tripModel.value!.invitedUsers!.add(email);
        
        // Update trip in Firebase
        await FirebaseTripService.updateTrip(
          tripId: tripModel.value!.id,
          data: {'invitedUsers': tripModel.value!.invitedUsers},
        );
        
        showCustomSnackBar(content: 'Invitation sent to $email');
      } else {
        showCustomSnackBar(content: 'User already invited');
      }
    } catch (e) {
      showCustomSnackBar(content: 'Failed to send invitation');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }
}
