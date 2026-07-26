import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_flight_model.dart';
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
  static const String tripShareBaseUrl =
      'https://travel-crew-web-101337609697.us-central1.run.app';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Rxn<DateTime> activityStartTime = Rxn<DateTime>();
  Rxn<DateTime> activityEndTime = Rxn<DateTime>();
  RxBool isLiked = false.obs;
  Rxn<TripModel> tripModel = Rxn<TripModel>();
  Rxn<TripDiscoveryModel> discoveryModel = Rxn<TripDiscoveryModel>();
  RxString joinRequestStatus = ''.obs;
  String? _initializedArgumentKey;
  RxBool isLocked = true.obs;
  final List<String> tripTabs = [
    'Transport',
    'Expense',
    'Lodging',
    'Activities',
  ];
  final selectedTabIndex = 0.obs;

  // Flight form state
  final TextEditingController flightAirlineController = TextEditingController();
  final TextEditingController flightNumberController = TextEditingController();
  final TextEditingController flightDepartureAirportController =
      TextEditingController();
  final TextEditingController flightArrivalAirportController =
      TextEditingController();
  final Rxn<DateTime> flightDepartureDate = Rxn<DateTime>();
  final Rxn<DateTime> flightArrivalDate = Rxn<DateTime>();

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
      showCustomSnackBar(content: 'Settlement marked as paid');
    } catch (e) {
      showCustomSnackBar(content: 'Failed to mark settlement');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(tripModel, (TripModel? trip) {
      if (trip != null && trip.flights == null) {
        loadFlights();
      }
    });
  }

  Future<void> initializeFromArgument(dynamic argument) async {
    final argumentKey = _argumentKey(argument);
    if (_initializedArgumentKey == argumentKey) return;
    _initializedArgumentKey = argumentKey;
    tripModel.value = null;
    discoveryModel.value = null;
    joinRequestStatus.value = '';
    if (argument is TripModel) {
      tripModel.value = argument;
      return;
    }
    if (argument is TripDiscoveryModel) {
      discoveryModel.value = argument;
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return;
      final isCreator = argument.createdBy == uid;
      final isMember = await FirebaseTripService.isTripMember(
        tripId: argument.id,
        userId: uid,
      );
      if (isCreator || isMember) {
        tripModel.value = await FirebaseTripService.getTripById(
          tripId: argument.id,
        );
      } else {
        final request = await FirebaseTripService.getJoinRequest(
          tripId: argument.id,
          userId: uid,
        );
        joinRequestStatus.value = request?.status ?? '';
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
      final success = await FirebaseTripService.requestToJoinTrip(
        trip.id,
        userId: uid,
      );
      if (success) {
        joinRequestStatus.value = 'pending';
        showCustomSnackBar(content: 'Request sent to the trip creator');
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
      final success = await FirebaseTripService.cancelJoinRequest(trip.id, uid);
      if (success) {
        joinRequestStatus.value = 'cancelled';
        showCustomSnackBar(content: 'Join request cancelled');
      }
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> acceptJoinRequest(String userId) async {
    final trip = tripModel.value;
    if (trip == null) return;
    try {
      GlobalVariables.showLoader.value = true;
      final success = await FirebaseTripService.acceptJoinRequest(
        trip.id,
        userId,
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
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> rejectJoinRequest(String userId) async {
    final trip = tripModel.value;
    if (trip == null) return;
    try {
      GlobalVariables.showLoader.value = true;
      final success = await FirebaseTripService.rejectJoinRequest(
        trip.id,
        userId,
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
    flightAirlineController.dispose();
    flightNumberController.dispose();
    flightDepartureAirportController.dispose();
    flightArrivalAirportController.dispose();
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

  void clearFlightForm() {
    flightAirlineController.clear();
    flightNumberController.clear();
    flightDepartureAirportController.clear();
    flightArrivalAirportController.clear();
    flightDepartureDate.value = null;
    flightArrivalDate.value = null;
  }

  Future<void> loadFlights() async {
    final tripId = tripModel.value?.id;
    if (tripId == null) return;
    final flights = await FirebaseTripService.getTripFlights(tripId: tripId);
    tripModel.value?.flights = flights;
    tripModel.refresh();
  }

  Future<void> addFlight() async {
    final tripId = tripModel.value?.id;
    if (tripId == null) {
      showCustomSnackBar(content: 'Trip not found');
      return;
    }
    try {
      GlobalVariables.showLoader.value = true;
      final flight = UserFlightModel(
        id: const Uuid().v6(),
        tripId: tripId,
        userId: GlobalVariables.currentUid,
        displayName: GlobalVariables.loggedInUser.value?.displayName,
        airlineName:
            flightAirlineController.text.trim().isEmpty
                ? null
                : flightAirlineController.text.trim(),
        flightNumber:
            flightNumberController.text.trim().isEmpty
                ? null
                : flightNumberController.text.trim(),
        departureAirport:
            flightDepartureAirportController.text.trim().isEmpty
                ? null
                : flightDepartureAirportController.text.trim(),
        arrivalAirport:
            flightArrivalAirportController.text.trim().isEmpty
                ? null
                : flightArrivalAirportController.text.trim(),
        departureDate: flightDepartureDate.value,
        arrivalDate: flightArrivalDate.value,
      );
      final success = await FirebaseTripService.addFlight(flight: flight);
      if (success) {
        tripModel.value?.flights ??= [];
        tripModel.value?.flights?.add(flight);
        tripModel.refresh();
        Get.back();
        showCustomSnackBar(content: 'Flight added');
      }
    } catch (e) {
      showCustomSnackBar(content: 'Failed to add flight');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> deleteFlight(String id) async {
    try {
      GlobalVariables.showLoader.value = true;
      final success = await FirebaseTripService.deleteFlight(
        id: id,
        tripId: tripModel.value?.id,
      );
      if (success) {
        tripModel.value?.flights?.removeWhere((f) => f.id == id);
        tripModel.refresh();
      }
    } catch (e) {
      showCustomSnackBar(content: 'Failed to delete flight');
    } finally {
      GlobalVariables.showLoader.value = false;
    }
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

  void initLodgingFromTrip() {
    final trip = tripModel.value;
    if (trip == null) return;
    lodgingTypeController.text = trip.lodgingType ?? '';
    lodgingHotelNameController.text = trip.hotelName ?? '';
    lodgingAddressController.text = trip.hotelAddress ?? '';
    lodgingCheckIn.value = trip.checkInDate;
    lodgingCheckOut.value = trip.checkOutDate;
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

  Future<void> saveLodging() async {
    final trip = tripModel.value;
    if (trip == null) return;
    try {
      GlobalVariables.showLoader.value = true;
      await FirebaseTripService.updateTrip(
        tripId: trip.id,
        data: {
          'lodgingType': lodgingTypeController.text,
          'hotelName': lodgingHotelNameController.text,
          'hotelAddress': lodgingAddressController.text,
          'checkInDate':
              lodgingCheckIn.value?.toIso8601String() ??
              trip.checkInDate?.toIso8601String(),
          'checkOutDate':
              lodgingCheckOut.value?.toIso8601String() ??
              trip.checkOutDate?.toIso8601String(),
        },
      ).then((success) {
        if (success) {
          tripModel.value = trip.copyWith(
            lodgingType: lodgingTypeController.text,
            hotelName: lodgingHotelNameController.text,
            hotelAddress: lodgingAddressController.text,
            checkInDate: lodgingCheckIn.value,
            checkOutDate: lodgingCheckOut.value,
          );
          updateTripOverAll(tripModel.value!);
          Get.back();
          showCustomSnackBar(content: 'Lodging updated successfully');
        } else {
          showCustomSnackBar(content: 'Failed to update lodging');
        }
      });
    } catch (e) {
      showCustomSnackBar(content: 'An error occurred');
    } finally {
      GlobalVariables.showLoader.value = false;
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
          showCustomSnackBar(content: 'Trip removed successfully');
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
        showCustomSnackBar(content: 'You have left the trip');
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
      await FirebaseTripService.likeActivity(
        activityId: activityId,
        isLiked: isLiked,
        userId: GlobalVariables.loggedInUser.value?.uid ?? '',
        tripId: tripModel.value?.id,
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
    } catch (e) {
      debugPrint('Failed to like activity: $e');
    }
  }

  Future<void> addActivity() async {
    try {
      if (activityEndTime.value == null || activityStartTime.value == null) {
        showCustomSnackBar(
          content: 'Please select start and end date and time',
        );
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
        id:
            toAdd
                ? const Uuid().v6()
                : (existingActivity?.id ?? const Uuid().v6()),
        tripId: tripId,
        title: activityNameController.text,
        location: locationController.text,
        startDateTime: activityStartTime.value ?? DateTime.now(),
        endDateTime: activityEndTime.value ?? DateTime.now(),
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
            (args['onAdded'] as Function?)?.call(activityModel);
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

    return '$tripShareBaseUrl/trip/${Uri.encodeComponent(trip.id)}';
  }

  Future<void> inviteToTrip() async {
    try {
      if (tripModel.value == null) {
        showCustomSnackBar(content: 'Trip not found');
        return;
      }

      final emailController = TextEditingController();
      Get.dialog(
        AlertDialog(
          title: const Text('Invite to Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter email address to invite:'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (email) {
                  if (email.isNotEmpty && email.contains('@')) {
                    _sendInvite(email);
                    Get.back();
                  } else {
                    showCustomSnackBar(
                      content: 'Please enter a valid email address',
                    );
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
                final email = emailController.text.trim();
                if (email.isNotEmpty && email.contains('@')) {
                  _sendInvite(email);
                  Get.back();
                } else {
                  showCustomSnackBar(
                    content: 'Please enter a valid email address',
                  );
                }
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

        final updated = await FirebaseTripService.updateTrip(
          tripId: tripModel.value!.id,
          data: {'invitedUsers': tripModel.value!.invitedUsers},
        );
        final sent = await FirebaseTripService.sendTripInvites(
          tripId: tripModel.value!.id,
          tripTitle: tripModel.value!.title ?? tripModel.value!.destination,
          emails: [email],
        );
        if (updated && sent) {
          showCustomSnackBar(content: 'Invitation sent to $email');
        } else {
          showCustomSnackBar(content: 'Failed to send invitation');
        }
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
