import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/aeroplanes_model.dart';
import 'package:travel_crew/models/search_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/aviation_stack_service/aviation_stack_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/geo_services.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/utils/common_code.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/debugging.dart';
import 'package:uuid/uuid.dart';

import '../../../models/expense_model.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_utils.dart';

class CreateTripController extends GetxController {
  RxBool isLocked = false.obs;
  RxString country = ''.obs;
  RxString selectedPlaceId = ''.obs;
  RxList<String> invitedUsersList = <String>[].obs;
  GlobalKey<FormState> formStep1 = GlobalKey<FormState>(),
      formStep2 = GlobalKey<FormState>(),
      formStep3 = GlobalKey<FormState>(),
      formStep4 = GlobalKey<FormState>(),
      formStep5 = GlobalKey<FormState>(),
      formStep6 = GlobalKey<FormState>(),
      formStep7 = GlobalKey<FormState>();

  RxList<SelectedImage> selectedImages = <SelectedImage>[].obs;

  Future<void> usePlacePhotoAsCoverIfNeeded() async {
    if (selectedImages.isNotEmpty ||
        selectedPlaceId.value.isEmpty ||
        selectedPlaceId.value == 'existing_location') {
      return;
    }

    final photoName = await getLocationDetails(selectedPlaceId.value);
    if (photoName != null) {
      selectedImages.add(
        SelectedImage(
          imageUrl: GeoServices.getPhotoUrl(photoName),
          isNetworkImage: true,
        ),
      );
    }
  }

  // Track the current step (1-6)
  final RxInt currentStep = 1.obs;
  RxList<ActivityModel> activityList = <ActivityModel>[].obs;
  // Total number of steps
  final int totalSteps = 1;
  Rxn<DateTime> startDate = Rxn<DateTime>();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  Rxn<DateTime> checkInStartTime = Rxn<DateTime>();
  Rxn<DateTime> checkInEndTime = Rxn<DateTime>();
  Rxn<DateTime> departureDate = Rxn<DateTime>();
  Rxn<DateTime> arrivalDate = Rxn<DateTime>();

  // Trip data
  final tripNameController = TextEditingController();
  final destinationController = TextEditingController(),
      airLineNameController = TextEditingController(),
      flightNumberController = TextEditingController(),
      hotelNameController = TextEditingController(),
      addressController = TextEditingController(),
      expensePerNightController = TextEditingController(),
      activityNameController = TextEditingController(),
      locationController = TextEditingController(),
      activityNoteController = TextEditingController(),
      searchFriendController = TextEditingController(),
      sendInviteEmailController = TextEditingController(),
      expenseNameController = TextEditingController(),
      amountPaidController = TextEditingController(),
      lodgingTypeController = TextEditingController(),
      airportArrivalController = TextEditingController(),
      airportDepartureController = TextEditingController();

  FocusNode destinationFocusNode = FocusNode(),
      lodgingTypeFocusNode = FocusNode(),
      airLineNameFocusNode = FocusNode(),
      flightNumberFocusNode = FocusNode(),
      hotelNameFocusNode = FocusNode(),
      addressFocusNode = FocusNode(),
      expensePerNightFocusNode = FocusNode(),
      activityNameFocusNode = FocusNode(),
      locationFocusNode = FocusNode(),
      activityNoteFocusNode = FocusNode(),
      searchFriendFocusNode = FocusNode(),
      sendInviteEmailFocusNode = FocusNode(),
      expenseNameFocusNode = FocusNode(),
      amountPaidFocusNode = FocusNode(),
      tripNameFocusNode = FocusNode(),
      airportArrivalFocusNode = FocusNode(),
      airportDepartureFocusNode = FocusNode();
  RxString flightNumer = ''.obs;

  Rxn<DateTime> activityStartTime = Rxn<DateTime>();
  Rxn<DateTime> activityEndTime = Rxn<DateTime>();
  Rxn<TripModel> tripModel = Rxn<TripModel>();
  void setFromImport(Map<String, dynamic> data) {
    try {
      tripNameController.text = (data['title'] as String?) ?? '';
      destinationController.text = (data['destination'] as String?) ?? '';
      country.value = (data['country'] as String?) ?? '';
      selectedLocation.value = destinationController.text;
      selectedPlaceId.value = 'existing_location';
      isLocked.value = (data['is_private'] as bool?) ?? false;

      if (data['start_date'] != null) {
        startDate.value = DateTime.tryParse(data['start_date'] as String);
      }
      if (data['end_date'] != null) {
        endDate.value = DateTime.tryParse(data['end_date'] as String);
      }

      _applyAirlineImport(data['airline']);
      _applyLodgingImport(data['lodging']);
      _applyActivitiesImport(data['activities']);
    } catch (e, stack) {
      kLogging('setFromImport error: $e\n$stack');
      showCustomSnackBar(
        content:
            'Some fields could not be imported — please fill them in manually',
      );
    }
  }

  void _applyAirlineImport(dynamic raw) {
    if (raw is! Map<String, dynamic>) return;
    airLineNameController.text = (raw['name'] as String?) ?? '';
    flightNumberController.text = (raw['flight_number'] as String?) ?? '';
    airportDepartureController.text =
        (raw['departure_airport'] as String?) ?? '';
    airportArrivalController.text = (raw['arrival_airport'] as String?) ?? '';
    if (raw['departure_date'] != null) {
      departureDate.value = DateTime.tryParse(raw['departure_date'] as String);
    }
    if (raw['arrival_date'] != null) {
      arrivalDate.value = DateTime.tryParse(raw['arrival_date'] as String);
    }
  }

  void _applyLodgingImport(dynamic raw) {
    if (raw is! Map<String, dynamic>) return;
    lodgingTypeController.text = (raw['type'] as String?) ?? '';
    hotelNameController.text = (raw['name'] as String?) ?? '';
    addressController.text = (raw['address'] as String?) ?? '';
    if (raw['check_in'] != null) {
      checkInStartTime.value = DateTime.tryParse(raw['check_in'] as String);
    }
    if (raw['check_out'] != null) {
      checkInEndTime.value = DateTime.tryParse(raw['check_out'] as String);
    }
    if (raw['cost_per_night'] != null) {
      expensePerNightController.text =
          (raw['cost_per_night'] as num).toString();
    }
  }

  void _applyActivitiesImport(dynamic raw) {
    if (raw is! List) return;
    activityList.value =
        raw
            .whereType<Map<String, dynamic>>()
            .map(
              (act) => ActivityModel(
                title: (act['title'] as String?) ?? '',
                description: (act['description'] as String?) ?? '',
                location: act['location'] as String?,
                startDateTime:
                    act['start_datetime'] != null
                        ? DateTime.tryParse(act['start_datetime'] as String)
                        : null,
                endDateTime:
                    act['end_datetime'] != null
                        ? DateTime.tryParse(act['end_datetime'] as String)
                        : null,
                tripId: '',
                likesCount: 0,
              ),
            )
            .toList();
  }

  void setAllValuesToEdit() {
    tripNameController.text = tripModel.value!.title ?? '';
    country.value = tripModel.value!.country;
    destinationController.text = tripModel.value!.tripLocation ?? '';
    airLineNameController.text = tripModel.value!.airlineName ?? '';
    airportArrivalController.text = tripModel.value!.arrivalAirport ?? '';
    airportDepartureController.text = tripModel.value!.departureAirport ?? '';
    flightNumberController.text = tripModel.value!.flightNumber ?? '';
    hotelNameController.text = tripModel.value!.hotelName ?? '';
    addressController.text = tripModel.value!.hotelAddress ?? '';
    invitedUsersList.value = tripModel.value!.invitedUsers ?? [];
    selectedLocation.value = tripModel.value!.tripLocation ?? '';
    // Set selectedPlaceId to a non-empty value when editing to bypass location validation
    selectedPlaceId.value = 'existing_location';
    arrivalDate.value = tripModel.value?.arrivalDate;
    departureDate.value = tripModel.value?.departureDate;
    expensePerNightController.text =
        tripModel.value!.expensePerNight.toString().isEmpty
            ? '0'
            : tripModel.value!.expensePerNight.toString();
    startDate.value = tripModel.value!.tripStartDate;
    endDate.value = tripModel.value!.tripEndDate;
    checkInStartTime.value = tripModel.value!.checkInDate;
    checkInEndTime.value = tripModel.value!.checkOutDate;
    selectedImages.value =
        (tripModel.value?.images ?? []).map((e) {
          return SelectedImage(imageUrl: e, isNetworkImage: true);
        }).toList();
    activityList.value = tripModel.value!.activities ?? [];
    // locationController.text = tripModel.value!.tripLocation ?? '';
    isLocked.value = tripModel.value!.isPrivate ?? true;
    hotelNameController.text = tripModel.value!.hotelName ?? '';
    addressController.text = tripModel.value!.hotelAddress ?? '';
    lodgingTypeController.text = tripModel.value!.lodgingType ?? '';
    invitedUsersList.value = tripModel.value!.invitedUsers ?? [];
  }

  // Move to the next step
  Future<void> nextStep() async {
    if (currentStep.value < totalSteps) {
      // Validate the current step's form
      if (currentStep.value == 1 && !formStep1.currentState!.validate()) {
        return;
      }
      // Only require location selection for new trips, not when editing
      if (selectedPlaceId.isEmpty && Get.arguments is! TripModel) {
        showCustomSnackBar(content: 'Please select trip location');
        return;
      }
      if (startDate.value == null || endDate.value == null) {
        showCustomSnackBar(content: 'Please select trip start and end date');
        return;
      }
      if (currentStep.value == 1 && selectedImages.isEmpty) {
        String? imageUrl;
        if (selectedPlaceId.value.isNotEmpty) {
          final photoName = await getLocationDetails(selectedPlaceId.value);
          if (photoName != null) {
            imageUrl = GeoServices.getPhotoUrl(photoName);
          }
        }
        imageUrl ??=
            'https://firebasestorage.googleapis.com/v0/b/universal-code-135522.appspot.com/o/travelcrew%2Fimages%2Ftravelcrew_image.png?alt=media&token=a90c5802-1b9e-44c9-b714-8a1cd3e1174f';
        selectedImages.add(
          SelectedImage(imageUrl: imageUrl, isNetworkImage: true),
        );
      }
      if (currentStep.value == 2 && !formStep2.currentState!.validate()) {
        return;
      } else if (currentStep.value == 3 &&
          !formStep3.currentState!.validate()) {
        return;
      }
      //  else if (currentStep.value == 4 && lodgingTypeController.text.isEmpty) {
      //   showCustomSnackBar(content: 'Please select lodging type');
      //   return;
      // }
      else if (currentStep.value == 4 && !formStep4.currentState!.validate()) {
        return;
      }
      //  else if (currentStep.value == 4 &&
      //     (checkInStartTime.value == null || checkInEndTime.value == null)) {
      //   showCustomSnackBar(
      //     content: 'Please select check-in and check-out time',
      //   );
      //   return;
      // }
      else if (activityList.isEmpty &&
          currentStep.value == 5 &&
          !formStep5.currentState!.validate()) {
        return;
      } else if (currentStep.value == 7 &&
          !formStep7.currentState!.validate()) {
        return;
      }
      if (Get.arguments is TripModel && currentStep.value == 6) {
        updateTrip();
        return;
      }
      currentStep.value++;
    } else {
      // Submit the trip
      kLogging('Submit trip');
      submitTrip();
    }
  }

  Future<void> updateTrip() async {
    try {
      List<String> uploadedImages = [];
      if (selectedImages.isNotEmpty) {
        int i = 0;
        final futures = selectedImages.map((e) async {
          i++;
          if (e.isNetworkImage) {
            return e.imageUrl;
          } else {
            final String imageUrl = await uploadImageToFirebaseStorage(
              imagePath: e.imageUrl,
              folderName: 'trip_images',
              title: 'Uploading trip image',
              subtitle: 'Uploading trip image',
              imageName:
                  '${tripModel.value!.id}${const Uuid().v6()}_trip_image$i',
            );
            return imageUrl;
          }
        });
        uploadedImages = await Future.wait(futures);
      }
      final TripModel trip = TripModel(
        images: uploadedImages,
        tripStatus: TripStatus.upcoming.name,
        id: tripModel.value!.id,
        tripLocation: destinationController.text,
        invitedUsers: invitedUsersList.isEmpty ? [] : invitedUsersList,
        joinedUsers: tripModel.value!.joinedUsers ?? [],
        tripBudget: double.parse(
          expensePerNightController.text.isEmpty
              ? '0'
              : expensePerNightController.text,
        ),
        isPrivate: isLocked.value,
        arrivalAirport: airportArrivalController.text,
        departureDate: departureDate.value ?? DateTime.now(),
        arrivalDate: arrivalDate.value ?? DateTime.now(),
        departureAirport: airportDepartureController.text,
        checkInDate: checkInStartTime.value ?? DateTime.now(),
        checkOutDate: checkInEndTime.value ?? DateTime.now(),
        country: destinationController.text.split(',').lastOrNull ?? '',
        startDate: startDate.value!,
        daysToGo: _calendarDaysUntil(startDate.value!),
        createdBy: GlobalVariables.currentUid,
        title: tripNameController.text,
        destination: destinationController.text,
        tripStartDate: startDate.value!,
        tripEndDate: endDate.value!,
        endDate: '',
        airlineName: airLineNameController.text,
        flightNumber: flightNumberController.text,
        hotelName: hotelNameController.text,
        hotelAddress: addressController.text,
        expensePerNight: double.parse(
          expensePerNightController.text.isEmpty
              ? '0'
              : expensePerNightController.text,
        ),
        lodgingType: lodgingTypeController.text,
      );
      GlobalVariables.showLoader.value = true;
      if (tripModel.value!.tripLocation != destinationController.text) {
        final LatLng latln = await GeoServices.getLatLngFromPlace(
          trip.tripLocation ?? '',
        );
        trip.latitude = latln.latitude;
        trip.longitude = latln.longitude;
      }

      await FirebaseTripService.updateTrip(
        tripId: trip.id,
        data: trip.toMap(),
      ).then((isSuccess) async {
        if (isSuccess) {
          showCustomSnackBar(content: 'Trip updated successfully');
          for (var i = 0; i < activityList.length; i++) {
            if (activityList[i].id == null) {
              activityList[i].id = const Uuid().v6();
              activityList[i].tripId = tripModel.value!.id;
              await FirebaseTripService.addActivity(activity: activityList[i]);
            }
          }
          final updatedTrip = trip.copyWith(activities: activityList);
          updatedTrip.expenses = tripModel.value!.expenses;
          updatedTrip.joindUsersList = tripModel.value!.joindUsersList;
          updatedTrip.createdByUser = tripModel.value!.createdByUser;
          tripModel.value = updatedTrip;
          updateTripOverAll(updatedTrip);
          Get.offAllNamed(kSpecificTripViewScreenRoute, arguments: updatedTrip);
        } else {
          showCustomSnackBar(content: 'Failed to update trip');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in updateTrip: $e');
      }
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  int _calendarDaysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    return targetDate.difference(today).inDays;
  }

  // Move to the previous step
  void previousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      // Go back to previous screen
      Get.back();
    }
  }

  // Submit the trip
  Future<void> submitTrip() async {
    try {
      final String id = const Uuid().v4();
      final TripModel tripModel = TripModel(
        tripStatus: TripStatus.upcoming.name,
        id: id,
        tripLocation: destinationController.text,
        invitedUsers: invitedUsersList.isEmpty ? [] : invitedUsersList,
        joinedUsers: [],
        tripBudget: double.parse(
          expensePerNightController.text.isEmpty
              ? '0'
              : expensePerNightController.text,
        ),
        isPrivate: isLocked.value,
        arrivalAirport: airportArrivalController.text,
        departureAirport: airportDepartureController.text,
        departureDate: departureDate.value ?? DateTime.now(),
        arrivalDate: arrivalDate.value ?? DateTime.now(),
        checkInDate: checkInStartTime.value ?? DateTime.now(),
        checkOutDate: checkInEndTime.value ?? DateTime.now(),
        country: destinationController.text.split(',').lastOrNull ?? '',
        startDate: startDate.value!,
        daysToGo: _calendarDaysUntil(startDate.value!),
        createdBy: GlobalVariables.currentUid,
        title: tripNameController.text,
        destination: destinationController.text,
        tripStartDate: startDate.value!,
        tripEndDate: endDate.value!,
        endDate: '',
        airlineName: airLineNameController.text,
        flightNumber: flightNumberController.text,
        hotelName: hotelNameController.text,
        hotelAddress: addressController.text,
        expensePerNight: double.parse(
          expensePerNightController.text.isEmpty
              ? '0'
              : expensePerNightController.text,
        ),
        lodgingType: lodgingTypeController.text,
        images: [],
      );
      GlobalVariables.showLoader.value = true;
      await usePlacePhotoAsCoverIfNeeded();
      List<String> uplaodedImages = [];
      if (selectedImages.isNotEmpty) {
        int i = 0;
        final futures = selectedImages.map((e) async {
          i++;
          if (e.isNetworkImage) {
            return e.imageUrl;
          } else {
            final String imageUrl = await uploadImageToFirebaseStorage(
              imagePath: e.imageUrl,
              folderName: 'travelcrew/trips',
              title: 'Uploading trip image',
              subtitle: 'Uploading trip image',
              imageName: '${'$id${const Uuid().v6()}'}_trip_image$i',
            );
            return imageUrl;
          }
        });
        uplaodedImages = await Future.wait(futures);
        tripModel.images = uplaodedImages;
      }
      final ExpenseModel exp = ExpenseModel(
        paidByUsers: [],
        date: expanseDate.value ?? DateTime.now(),
        id: const Uuid().v6(),
        createdBy: GlobalVariables.currentUid,
        tripId: tripModel.id,
        name: expenseNameController.text,
        amount: double.parse(
          amountPaidController.text.isEmpty ? '0' : amountPaidController.text,
        ),
      );
      final LatLng latln = await GeoServices.getLatLngFromPlace(
        tripModel.tripLocation ?? '',
      );
      tripModel.latitude = latln.latitude;
      tripModel.longitude = latln.longitude;
      tripModel.continent = CommonCode.getContinentFromLatLng(
        tripModel.latitude,
        tripModel.longitude,
      );
      await FirebaseTripService.addTrip(tripModel: tripModel).then((
        isSuccess,
      ) async {
        if (isSuccess) {
          showCustomSnackBar(content: 'Trip created successfully');
          await FirebaseTripService.sendTripInvites(
            tripId: tripModel.id,
            tripTitle: tripModel.title ?? tripModel.destination,
            emails: invitedUsersList,
          );
          await FirebaseTripService.addExpenses(expense: exp).then((
            isSuccess,
          ) async {
            GlobalVariables.showLoader.value = false;
            if (isSuccess) {
              for (var i = 0; i < activityList.length; i++) {
                activityList[i].tripId = tripModel.id;
                activityList[i].id = const Uuid().v6();
                await FirebaseTripService.addActivity(
                  activity: activityList[i],
                );
              }
              tripModel.activities = activityList;
              tripModel.expenses = [exp];
              addTripOverAll(tripModel);
              Get.offAndToNamed(
                kSpecificTripViewScreenRoute,
                arguments: tripModel,
              );
            } else {
              showCustomSnackBar(content: 'Failed to add expense');
            }
          });
        } else {
          showCustomSnackBar(content: 'Failed to create trip');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in submitTrip: $e');
      }
      showCustomSnackBar(
        content: e.toString(),
        contentType: ContentType.failure,
      );
    }
    GlobalVariables.showLoader.value = false;
    // Get.offAndToNamed(
    //   kSpecificTripViewScreenRoute,
    //   arguments: {'isOpenChat': true},
    // );
  }

  // Get button text based on current step
  String getButtonText() {
    return currentStep.value == totalSteps ? 'Create Trip' : 'Next';
  }

  RxString selectedLocation = ''.obs;
  RxString searchText = ''.obs;

  Rxn<DateTime?> expanseDate = Rxn<DateTime?>();

  RxList<SearchModel> locations = RxList();
  RxList<SearchModel> hotelLocations = RxList();
  RxList<SearchModel> searchedFriends = RxList();

  void updateSearch(String value) {
    searchText.value = value;
  }

  RxInt isLoadingSuggestions = (-1).obs;

  RxList<AeroplanesModel> airlineList = RxList();
  Future<void> fetchLocation(String? value, {int id = -1, String? type}) async {
    if (value == null || value.isEmpty) {
      locations.clear();
      return;
    }
    isLoadingSuggestions.value = id;
    await GeoServices.fetchPlaceSuggestions(value, type: type).then((
      suggestions,
    ) async {
      locations.clear();
      for (final e in suggestions) {
        locations.add(
          SearchModel(
            searchText: e['description'] ?? '',
            placeId: e['place_id'],
          ),
        );
      }
    });
    if (locations.isNotEmpty) {
      GlobalVariables.showDropdown.value = true;
    } else {
      GlobalVariables.showDropdown.value = false;
    }
  }

  Future<void> fetchHotelLocation(String? value, {int id = -1}) async {
    if (value == null || value.isEmpty) {
      hotelLocations.clear();
      return;
    }
    isLoadingSuggestions.value = id;
    await GeoServices.fetchPlaceSuggestions(value, type: 'lodging').then((
      suggestions,
    ) async {
      hotelLocations.clear();
      for (final e in suggestions) {
        hotelLocations.add(
          SearchModel(
            searchText: e['description'] ?? '',
            placeId: e['place_id'],
          ),
        );
      }
    });
    if (hotelLocations.isNotEmpty) {
      GlobalVariables.showDropdown.value = true;
    } else {
      GlobalVariables.showDropdown.value = false;
    }
  }

  Future getLocationDetails(String value) async {
    try {
      return await GeoServices.getLocationDetailsFromPlaceId(value).then((
        location,
      ) {
        if (location != null &&
            location['photos'] != null &&
            (location['photos'] as List).isNotEmpty) {
          return location['photos'][0]['name'];
        }
        return null;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in getLocationDetails: $e');
      }
    }
    return null;
  }

  Future<void> fetchAeroPlanes(String? value) async {
    try {
      if (value == null || value.isEmpty) {
        airlineList.clear();
        return;
      }
      await AviationStackService.fetchAirportSuggestions(query: value).then((
        suggestions,
      ) {
        airlineList.clear();
        // for (var e in suggestions) {
        //   airlineList.add(
        //     AeroplanesModel(
        //       iataCode: e['iata_code'] ?? '',
        //       name: e['airport_name'] ?? '',
        //       city: e['city'] ?? '',
        //       countryName: e['country_name'] ?? '',
        //     ),
        //   );
        // }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in fetchAeroPlanes: $e');
      }
      showCustomSnackBar(content: 'Failed to fetch aeroplanes');
    }
  }

  Future<void> removeActivity(String? id, int index) async {
    try {
      if (id == null || id.isEmpty) {
        activityList.removeAt(index);
        activityList.refresh();
      } else {
        await FirebaseTripService.deleteActivity(
          id: id,
          tripId: tripModel.value?.id,
        ).then((isSuccess) {
          if (isSuccess) {
            activityList.removeAt(index);
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in removeActivity: $e');
      }
    }
  }

  Future<void> searchFriends() async {
    try {
      if (searchFriendController.text.isEmpty) {
        return;
      }
      await FirebaseTripService.searchUser(
        query: searchFriendController.text,
      ).then((users) {
        searchedFriends.clear();
        for (final e in users) {
          searchedFriends.add(
            SearchModel(
              searchText: e.displayName,
              placeId: e.uid,
              imageUrl: e.profileImage,
            ),
          );
        }
        if (searchedFriends.isNotEmpty) {
          GlobalVariables.showDropdown.value = true;
        } else {
          GlobalVariables.showDropdown.value = false;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error in searchFriends: $e');
      }
      showCustomSnackBar(content: 'Failed to fetch friends');
    }
  }

  @override
  void onClose() {
    tripNameController.dispose();
    destinationController.dispose();
    airLineNameController.dispose();
    flightNumberController.dispose();
    hotelNameController.dispose();
    addressController.dispose();
    expensePerNightController.dispose();
    activityNameController.dispose();
    locationController.dispose();
    activityNoteController.dispose();
    searchFriendController.dispose();
    sendInviteEmailController.dispose();
    expenseNameController.dispose();
    amountPaidController.dispose();
    lodgingTypeController.dispose();
    airportArrivalController.dispose();
    airportDepartureController.dispose();

    destinationFocusNode.dispose();
    lodgingTypeFocusNode.dispose();
    airLineNameFocusNode.dispose();
    flightNumberFocusNode.dispose();
    hotelNameFocusNode.dispose();
    addressFocusNode.dispose();
    expensePerNightFocusNode.dispose();
    activityNameFocusNode.dispose();
    locationFocusNode.dispose();
    activityNoteFocusNode.dispose();
    searchFriendFocusNode.dispose();
    sendInviteEmailFocusNode.dispose();
    expenseNameFocusNode.dispose();
    amountPaidFocusNode.dispose();
    tripNameFocusNode.dispose();
    airportArrivalFocusNode.dispose();
    airportDepartureFocusNode.dispose();
    super.onClose();
  }
}

class SelectedImage {
  SelectedImage({required this.imageUrl, this.isNetworkImage = false});
  String imageUrl;
  bool isNetworkImage;
}
