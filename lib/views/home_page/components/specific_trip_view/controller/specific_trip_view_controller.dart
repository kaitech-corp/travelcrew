import 'package:travel_crew/utils/travel_time.dart';
import 'dart:async';
import 'package:travel_crew/models/lodging_model.dart';
import 'package:travel_crew/models/finance_amount.dart';
import 'package:travel_crew/services/lodging_service.dart';
import 'package:travel_crew/services/trip_invitation_service.dart';
import '../invite_travelers_dialog.dart';
import 'package:travel_crew/models/join_request_model.dart';
import 'package:flutter/material.dart';
import 'package:travel_crew/services/recommendation_runtime.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/expense_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/geo_services.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../../models/search_model.dart';

class SpecificTripViewController extends GetxController
    with GetSingleTickerProviderStateMixin {
  SpecificTripViewController({
    Future<bool> Function({
      required String id,
      String? tripId,
      required int expectedRevision,
    })?
    deleteActivity,
    Future<TripModel?> Function({required String tripId})? loadTrip,
    Future<bool> Function({required String tripId, required String userId})?
    checkTripMember,
  }) : _deleteActivity = deleteActivity ?? FirebaseTripService.deleteActivity,
       _loadTrip = loadTrip ?? FirebaseTripService.getTripById,
       _checkTripMember = checkTripMember ?? FirebaseTripService.isTripMember;

  final Future<bool> Function({
    required String id,
    String? tripId,
    required int expectedRevision,
  })
  _deleteActivity;
  final Future<TripModel?> Function({required String tripId}) _loadTrip;
  final Future<bool> Function({required String tripId, required String userId})
  _checkTripMember;
  final Set<String> _deletingActivities = {};

  bool canManageActivity(ActivityModel activity) {
    final uid = GlobalVariables.currentUid;
    return uid.isNotEmpty &&
        (uid == tripModel.value?.createdBy || uid == activity.createdBy);
  }

  Future<bool> removeActivity(ActivityModel activity) async {
    final trip = tripModel.value;
    final id = activity.id;
    if (trip == null ||
        id == null ||
        id.isEmpty ||
        !canManageActivity(activity) ||
        !_deletingActivities.add(id)) {
      return false;
    }
    try {
      final success = await _deleteActivity(
        id: id,
        tripId: activity.isLegacy ? null : trip.id,
        expectedRevision: activity.contentRevision,
      );
      if (success) {
        trip.activities?.removeWhere((item) => item.id == id);
        tripModel.refresh();
        updateTripOverAll(trip);
      }
      return success;
    } catch (_) {
      return false;
    } finally {
      _deletingActivities.remove(id);
    }
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Rxn<DateTime> activityStartTime = Rxn<DateTime>();
  Rxn<DateTime> activityEndTime = Rxn<DateTime>();
  RxBool isLiked = false.obs;
  Rxn<TripModel> tripModel = Rxn<TripModel>();
  Rxn<TripDiscoveryModel> discoveryModel = Rxn<TripDiscoveryModel>();
  final RxBool isLoadingTrip = false.obs;
  final RxnString tripLoadError = RxnString();
  int _initializationVersion = 0;
  RxString joinRequestStatus = ''.obs;
  String joinAttemptId = 'legacy';
  StreamSubscription<JoinRequestModel?>? _joinRequestSubscription;
  String? _initializedArgumentKey;
  RxBool isLocked = true.obs;
  final List<String> tripTabs = [
    'Transport',
    'Expense',
    'Lodging',
    'Activities',
  ];
  final selectedTabIndex = 0.obs;

  List<Settlement> get optimalSettlements =>
      tripModel.value != null
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
      // showCustomSnackBar(content: 'Settlement marked as paid');
    } catch (e) {
      showCustomSnackBar(content: 'Failed to mark settlement');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> initializeFromArgument(dynamic argument) async {
    final version = ++_initializationVersion;
    final accountUid = GlobalVariables.currentUid;
    isLoadingTrip.value = true;
    tripLoadError.value = null;
    try {
      await _initializeFromArgument(argument, version);
    } catch (error) {
      AppLogger.warning('Unable to load trip details: ${error.runtimeType}');
      if (version == _initializationVersion &&
          accountUid == GlobalVariables.currentUid) {
        tripLoadError.value =
            'Unable to load trip. Check your connection and retry.';
      }
    } finally {
      if (version == _initializationVersion) isLoadingTrip.value = false;
    }
  }

  Future<void> _initializeFromArgument(dynamic argument, int version) async {
    final argumentKey = _argumentKey(argument);
    _initializedArgumentKey = argumentKey;
    await _joinRequestSubscription?.cancel();
    if (version != _initializationVersion) return;
    _joinRequestSubscription = null;
    tripModel.value = null;
    discoveryModel.value = null;
    joinRequestStatus.value = '';
    if (argument is TripModel) {
      final uid = GlobalVariables.currentUid;
      if (uid.isEmpty) return;
      final loaded = await _loadTrip(tripId: argument.id);
      if (version != _initializationVersion ||
          uid != GlobalVariables.currentUid) {
        return;
      }
      tripModel.value = loaded;
      if (loaded == null) tripLoadError.value = 'Trip unavailable.';
      return;
    }
    if (argument is TripDiscoveryModel) {
      discoveryModel.value = argument;
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return;
      final isCreator = argument.createdBy == uid;
      final isMember =
          !isCreator &&
          await _checkTripMember(tripId: argument.id, userId: uid);
      if (version != _initializationVersion ||
          uid != GlobalVariables.currentUid) {
        return;
      }
      if (isCreator || isMember) {
        final loaded = await _loadTrip(tripId: argument.id);
        if (version != _initializationVersion ||
            uid != GlobalVariables.currentUid) {
          return;
        }
        tripModel.value = loaded;
        if (loaded == null) tripLoadError.value = 'Trip unavailable.';
      } else {
        final request = await FirebaseTripService.getJoinRequest(
          tripId: argument.id,
          userId: uid,
        );
        if (version != _initializationVersion ||
            uid != GlobalVariables.currentUid) {
          return;
        }
        joinRequestStatus.value = request?.status ?? '';
        joinAttemptId = request?.attemptId ?? 'legacy';
        _joinRequestSubscription = FirebaseTripService.watchJoinRequest(
          tripId: argument.id,
          userId: uid,
        ).listen(
          (current) async {
            if (_initializedArgumentKey != argumentKey ||
                GlobalVariables.currentUid != uid) {
              return;
            }
            try {
              joinRequestStatus.value = current?.status ?? '';
              joinAttemptId = current?.attemptId ?? 'legacy';
              if (current?.status == 'accepted' &&
                  await _checkTripMember(tripId: argument.id, userId: uid)) {
                final joined = await _loadTrip(tripId: argument.id);
                if (_initializedArgumentKey == argumentKey &&
                    GlobalVariables.currentUid == uid) {
                  tripModel.value = joined;
                  tripLoadError.value =
                      joined == null ? 'Trip unavailable.' : null;
                }
              }
            } catch (error) {
              AppLogger.warning(
                'Unable to refresh accepted trip: ${error.runtimeType}',
              );
              if (_initializedArgumentKey == argumentKey &&
                  GlobalVariables.currentUid == uid) {
                tripLoadError.value =
                    'Unable to load trip. Check your connection and retry.';
              }
            }
          },
          onError: (Object error) {
            AppLogger.warning(
              'Unable to refresh join request: ${error.runtimeType}',
            );
            if (_initializedArgumentKey == argumentKey &&
                GlobalVariables.currentUid == uid) {
              tripLoadError.value =
                  'Unable to load trip. Check your connection and retry.';
            }
          },
        );
      }
      return;
    }
    if (argument is Map && argument['trip'] is TripModel) {
      tripModel.value = argument['trip'] as TripModel;
    }
  }

  String _argumentKey(dynamic argument) {
    if (argument is TripModel) return 'trip:${argument.id}';
    if (argument is TripDiscoveryModel) return 'discovery:${argument.id}';
    if (argument is Map && argument['trip'] is TripModel) {
      return 'trip:${(argument['trip'] as TripModel).id}';
    }
    return 'unknown:${identityHashCode(argument)}';
  }

  bool get isPublicPreview =>
      tripModel.value == null && discoveryModel.value != null;

  Future<void> requestToJoinPublicPreview() async {
    final trip = discoveryModel.value;
    final uid = GlobalVariables.loggedInUser.value?.uid;
    if (trip == null || uid == null) {
      showCustomSnackBar(content: 'Please log in to request to join');
      return;
    }
    try {
      GlobalVariables.showLoader.value = true;
      await RecommendationRuntime.service.flush().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
      final success = await FirebaseTripService.requestToJoinTrip(
        trip.id,
        userId: uid,
        recommendation: trip.recommendation,
      );
      if (success) {
        try {
          final request = await FirebaseTripService.getJoinRequest(
            tripId: trip.id,
            userId: uid,
          );
          joinRequestStatus.value = request?.status ?? '';
          joinAttemptId = request?.attemptId ?? 'legacy';
          showCustomSnackBar(content: 'Request sent to the trip creator');
        } catch (error) {
          AppLogger.warning(
            'Join request sent but status unavailable: ${error.runtimeType}',
          );
          showCustomSnackBar(
            content:
                'Request sent, but status could not load. Reopen the trip.',
          );
        }
      } else {
        showCustomSnackBar(content: 'Failed to send request');
      }
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> cancelPublicJoinRequest() async {
    final trip = discoveryModel.value;
    final uid = GlobalVariables.loggedInUser.value?.uid;
    if (trip == null || uid == null) return;
    try {
      GlobalVariables.showLoader.value = true;
      final success = await FirebaseTripService.cancelJoinRequest(
        trip.id,
        uid,
        attemptId: joinAttemptId,
      );
      if (success) {
        joinRequestStatus.value = 'cancelled';
        showCustomSnackBar(content: 'Join request cancelled');
      } else {
        showCustomSnackBar(
          content: 'This request changed. Reopen the trip to refresh.',
        );
      }
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> acceptJoinRequest(String userId, String attemptId) async {
    final trip = tripModel.value;
    if (trip == null) return;
    try {
      GlobalVariables.showLoader.value = true;
      final success = await FirebaseTripService.acceptJoinRequest(
        trip.id,
        userId,
        attemptId: attemptId,
      );
      if (success) {
        final refreshed = await FirebaseTripService.getTripById(
          tripId: trip.id,
        );
        if (refreshed != null) {
          tripModel.value = refreshed;
          updateTripOverAll(refreshed);
        }
        showCustomSnackBar(content: 'Join request accepted');
      } else {
        showCustomSnackBar(content: 'Failed to accept request');
      }
    } catch (error) {
      AppLogger.warning(
        'Unable to refresh accepted trip: ${error.runtimeType}',
      );
      showCustomSnackBar(
        content:
            'Request may be accepted, but the trip could not refresh. Reopen it.',
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> rejectJoinRequest(String userId, String attemptId) async {
    final trip = tripModel.value;
    if (trip == null) return;
    try {
      GlobalVariables.showLoader.value = true;
      final success = await FirebaseTripService.rejectJoinRequest(
        trip.id,
        userId,
        attemptId: attemptId,
      );
      if (success) {
        showCustomSnackBar(content: 'Join request rejected');
      } else {
        showCustomSnackBar(content: 'Failed to reject request');
      }
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  @override
  void onClose() {
    _initializationVersion++;
    _joinRequestSubscription?.cancel();
    lodgingCostController.dispose();
    lodgingTypeController.dispose();
    lodgingHotelNameController.dispose();
    lodgingAddressController.dispose();
    activityNoteController.dispose();
    activityNameController.dispose();
    locationController.dispose();
    hotelNameFocusNode.dispose();
    lodgingAddressFocusNode.dispose();
    activityNameFocusNode.dispose();
    activityNoteFocusNode.dispose();
    locationFocusNode.dispose();
    super.onClose();
  }

  TextEditingController activityNoteController = TextEditingController(),
      activityNameController = TextEditingController(),
      locationController = TextEditingController();

  FocusNode activityNameFocusNode = FocusNode(),
      activityNoteFocusNode = FocusNode(),
      locationFocusNode = FocusNode();

  RxString searchText = ''.obs;

  // Lodging form state
  final TextEditingController lodgingTypeController = TextEditingController();
  final TextEditingController lodgingHotelNameController =
      TextEditingController();
  final TextEditingController lodgingAddressController =
      TextEditingController();
  final Rxn<DateTime> lodgingCheckIn = Rxn<DateTime>();
  final Rxn<DateTime> lodgingCheckOut = Rxn<DateTime>();
  final RxList<SearchModel> hotelLocations = <SearchModel>[].obs;
  final RxString lodgingHotelSearchText = ''.obs;
  final FocusNode hotelNameFocusNode = FocusNode();
  final FocusNode lodgingAddressFocusNode = FocusNode();

  LodgingModel? editingLodging;
  final lodgingCostController = TextEditingController();
  final RxnString lodgingCurrencyCode = RxnString();

  void initLodgingForm([LodgingModel? option]) {
    editingLodging = option;
    lodgingTypeController.text = option?.lodgingType ?? '';
    lodgingHotelNameController.text = option?.hotelName ?? '';
    lodgingAddressController.text = option?.hotelAddress ?? '';
    lodgingCheckIn.value = option?.checkInDate;
    lodgingCheckOut.value = option?.checkOutDate;
    final nightlyCost = option?.expensePerNight;
    lodgingCostController.text =
        nightlyCost == null
            ? ''
            : nightlyCost == nightlyCost.truncateToDouble()
            ? nightlyCost.toInt().toString()
            : nightlyCost.toString();
    lodgingCurrencyCode.value = option?.currencyCode;
    searchText.value = option?.hotelAddress ?? '';
    locations.clear();
  }

  Future<void> fetchHotelLocations(String? value) async {
    if (value == null || value.isEmpty) {
      hotelLocations.clear();
      return;
    }
    await GeoServices.fetchPlaceSuggestions(value, type: 'lodging').then((
      suggestions,
    ) {
      hotelLocations.value =
          suggestions
              .map(
                (e) => SearchModel(
                  searchText: e['description'] ?? '',
                  placeId: e['place_id'],
                ),
              )
              .toList();
    });
  }

  Future<void> fetchLodgingAddressLocations(String? value) async {
    if (value == null || value.isEmpty) {
      locations.clear();
      return;
    }
    await GeoServices.fetchSuggestions(value).then((suggestions) {
      locations.value =
          suggestions
              .map(
                (e) => SearchModel(
                  searchText: e['description'] ?? '',
                  placeId: e['place_id'],
                ),
              )
              .toList();
    });
  }

  Future<void> saveLodging(Map<String, int>? supportedCurrencies) async {
    final trip = tripModel.value;
    if (trip == null || GlobalVariables.showLoader.value) return;
    final costText = lodgingCostController.text.trim();
    final cost = double.tryParse(costText);
    if (costText.isNotEmpty &&
        (cost == null || !cost.isFinite || cost < 0 || cost >= 1000000000)) {
      showCustomSnackBar(content: 'Enter a valid nightly cost');
      return;
    }
    final currency = cost == null ? null : lodgingCurrencyCode.value;
    final precision = supportedCurrencies?[currency];
    if (cost != null) {
      if (currency == null || precision == null) {
        showCustomSnackBar(content: 'Choose a currency for the nightly cost');
        return;
      }
      try {
        FinanceAmount.parseShareMinor(costText, precision);
      } on FormatException {
        showCustomSnackBar(
          content: 'Use the selected currency’s decimal precision',
        );
        return;
      }
    }
    if (lodgingHotelNameController.text.trim().length > 500 ||
        lodgingAddressController.text.trim().length > 2000 ||
        lodgingTypeController.text.trim().length > 100) {
      showCustomSnackBar(content: 'Lodging details are too long');
      return;
    }
    if (lodgingHotelNameController.text.trim().isEmpty &&
        lodgingAddressController.text.trim().isEmpty) {
      showCustomSnackBar(content: 'Enter a lodging name or address');
      return;
    }
    if ((lodgingCheckIn.value == null) != (lodgingCheckOut.value == null)) {
      showCustomSnackBar(content: 'Set both check-in and check-out');
      return;
    }
    if (lodgingCheckIn.value != null &&
        lodgingCheckOut.value != null &&
        TravelTime.serialize(
                  lodgingCheckOut.value,
                  editingLodging?.timeOffsets['checkOutDate'],
                )!
                .substring(0, 16)
                .compareTo(
                  TravelTime.serialize(
                    lodgingCheckIn.value,
                    editingLodging?.timeOffsets['checkInDate'],
                  )!.substring(0, 16),
                ) <=
            0) {
      showCustomSnackBar(content: 'Check-out must be after check-in');
      return;
    }
    final option = LodgingModel(
      timeOffsets: editingLodging?.timeOffsets ?? const {},
      id: editingLodging?.id ?? const Uuid().v4(),
      createdBy: editingLodging?.createdBy ?? GlobalVariables.currentUid,
      lodgingType: lodgingTypeController.text,
      hotelName: lodgingHotelNameController.text,
      hotelAddress: lodgingAddressController.text,
      checkInDate: lodgingCheckIn.value,
      checkOutDate: lodgingCheckOut.value,
      expensePerNight: cost,
      currencyCode: currency,
      revision: editingLodging?.revision ?? 0,
    );
    try {
      GlobalVariables.showLoader.value = true;
      if (option.id == 'legacy') {
        await LodgingService.saveLegacy(trip.id, editingLodging!, option);
        final data =
            option.toMap()
              ..remove('createdBy')
              ..remove('revision')
              ..remove('isDeleted');
        data['lodgingCurrencyCode'] = data.remove('currencyCode');
        final updated = TripModel.fromMap({...trip.toMap(), ...data});
        updated.createdByUser = trip.createdByUser;
        updated.joindUsersList = trip.joindUsersList;
        tripModel.value = updated;
        updateTripOverAll(updated);
      } else {
        await LodgingService.save(
          trip.id,
          option,
          isNew: editingLodging == null,
        );
      }
      Get.back();
    } catch (error) {
      showCustomSnackBar(
        content:
            error is StateError && error.message.contains('changed')
                ? 'Lodging changed on another device. Reopen it before saving.'
                : 'Unable to save lodging. Please try again.',
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<bool> refreshLegacyLodgingAfterDelete() async {
    final trip = tripModel.value;
    if (trip == null) return false;
    try {
      final refreshed = await FirebaseTripService.getTripById(tripId: trip.id);
      if (refreshed == null) return false;
      tripModel.value = refreshed;
      updateTripOverAll(refreshed);
      return true;
    } catch (_) {
      return false;
    }
  }

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
          // showCustomSnackBar(content: 'Trip removed successfully');
        } else {
          showCustomSnackBar(content: 'Failed to remove trip');
        }
      });
    } catch (e) {
      debugPrint('Failed to remove trip: $e');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> leaveTrip() async {
    final trip = tripModel.value;
    if (trip == null) return;
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty) return;
    GlobalVariables.showLoader.value = true;
    try {
      final ok = await FirebaseTripService.leaveGroup(
        groupId: trip.id,
        userId: uid,
      );
      if (ok) {
        removeTripOverAll(trip);
        Get.offAllNamed(kMainViewScreenRoute);
        // showCustomSnackBar(content: 'You have left the trip');
      } else {
        showCustomSnackBar(content: 'Failed to leave trip');
      }
    } catch (e) {
      AppLogger.error('Failed to leave trip: $e');
      showCustomSnackBar(content: 'Failed to leave trip');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> likeActivity({
    required String activityId,
    bool isLiked = false,
  }) async {
    try {
      final activityIndex =
          tripModel.value?.activities?.indexWhere(
            (item) => item.id == activityId,
          ) ??
          -1;
      if (activityIndex < 0) return;
      final activity = tripModel.value!.activities![activityIndex];
      final vote = await FirebaseTripService.likeActivity(
        activityId: activityId,
        isLiked: isLiked,
        userId: GlobalVariables.loggedInUser.value?.uid ?? '',
        tripId: activity.isLegacy ? null : tripModel.value?.id,
      );
      if (vote == null) {
        showCustomSnackBar(content: 'Failed to like activity');
        return;
      }
      final trip = tripModel.value;
      if (trip == null) return;
      final index =
          trip.activities?.indexWhere((item) => item.id == activityId) ?? -1;
      if (index < 0) return;
      trip.activities![index].likedBy = vote.likedBy;
      trip.activities![index].likesCount = vote.likesCount;
      tripModel.refresh();
      updateTripOverAll(trip);
    } catch (e) {
      debugPrint('Failed to like activity: $e');
    }
  }

  Future<void> addActivity() async {
    try {
      final scheduleError = ActivityModel.scheduleError(
        activityStartTime.value,
        activityEndTime.value,
      );
      if (scheduleError != null) {
        showCustomSnackBar(content: scheduleError);
        return;
      }
      if (activityNameController.text.trim().isEmpty) {
        showCustomSnackBar(content: 'Enter an activity name');
        return;
      }
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final bool toAdd = args['toAdd'] as bool? ?? true;
      final String tripId =
          args['tripId'] as String? ?? tripModel.value?.id ?? '';
      if (tripId.isEmpty) {
        showCustomSnackBar(content: 'Trip not found');
        return;
      }
      final ActivityModel? existingActivity =
          args['activity'] as ActivityModel?;
      GlobalVariables.showLoader.value = true;
      final ActivityModel activityModel = ActivityModel(
        isLegacy: !toAdd && existingActivity?.isLegacy == true,
        contentRevision: toAdd ? 1 : (existingActivity?.contentRevision ?? 0),
        createdBy:
            toAdd
                ? GlobalVariables.currentUid
                : (existingActivity?.createdBy ?? ''),
        timeOffsets:
            toAdd ? const {} : (existingActivity?.timeOffsets ?? const {}),
        id:
            toAdd
                ? const Uuid().v6()
                : (existingActivity?.id ?? const Uuid().v6()),
        tripId: tripId,
        title: activityNameController.text.trim(),
        location: locationController.text,
        startDateTime: activityStartTime.value,
        endDateTime: activityEndTime.value,
        description: activityNoteController.text,
        likedBy: toAdd ? [] : (existingActivity?.likedBy ?? []),
        likesCount: toAdd ? 0 : (existingActivity?.likesCount ?? 0),
      );
      if (toAdd) {
        await FirebaseTripService.addActivity(activity: activityModel).then((
          value,
        ) {
          GlobalVariables.showLoader.value = false;
          if (value) {
            (args['onAdded'] as Function?)?.call(activityModel);
            Get.back();
            // showCustomSnackBar(content: 'Activity added successfully');
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
            (args['onAdded'] as Function?)?.call(activityModel);
            Get.back();
            // showCustomSnackBar(content: 'Activity updated successfully');
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
    } catch (e) {
      debugPrint('Failed to fetch locations: $e');
    }
  }

  Future<bool> doitFavourite(String? id, {required bool isFavourites}) async {
    try {
      GlobalVariables.addingToFavourites.value = id ?? '';
      // await AuthService.addToFavourites(
      //   id: id ?? '',
      //   isFavourites: isFavourites,
      // ).then((value) {});
    } catch (e) {
      debugPrint('Failed to update favourite state: $e');
    }
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
        showCustomSnackBar(content: 'Request sent to the trip creator');
      } else {
        showCustomSnackBar(
          content: 'Failed to request access. Please try again.',
        );
      }
    } catch (e) {
      showCustomSnackBar(content: 'An error occurred while joining the trip');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<String?> createShareLink() async {
    final trip = tripModel.value;
    if (trip == null || trip.id.isEmpty) {
      showCustomSnackBar(content: 'Trip not found');
      return null;
    }

    if (!trip.isShared) {
      GlobalVariables.showLoader.value = true;
      try {
        final updated = await FirebaseTripService.updateTrip(
          tripId: trip.id,
          data: {'isShared': true},
        );
        if (!updated) {
          showCustomSnackBar(content: 'Unable to share this trip');
          return null;
        }
        trip.isShared = true;
        tripModel.refresh();
      } finally {
        GlobalVariables.showLoader.value = false;
      }
    }

    return '$kWebsiteBaseUrl/trip/${Uri.encodeComponent(trip.id)}';
  }

  Future<void> inviteToTrip() async {
    final trip = tripModel.value;
    if (trip == null) {
      showCustomSnackBar(content: 'Trip not found');
      return;
    }
    if (!GlobalVariables.isLoggedInUser(trip.createdBy)) {
      showCustomSnackBar(content: 'Only the trip owner can invite travelers');
      return;
    }
    await Get.dialog<void>(
      InviteTravelersDialog(
        search: (query) => TripInvitationService.search(trip.id, query),
        send:
            (userId, requestId) =>
                TripInvitationService.send(trip.id, userId, requestId),
        sendEmail:
            (email, requestId) => FirebaseTripService.sendTripInvites(
              tripId: trip.id,
              tripTitle: trip.title ?? trip.destination,
              emails: [email],
              requestId: requestId,
            ),
      ),
      barrierDismissible: false,
    );
  }
}
