import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxBool isLocked = true.obs;
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
  // Track the current step (1-6)
  final RxInt currentStep = 1.obs;
  RxList<ActivityModel> activityList = <ActivityModel>[].obs;
  // Total number of steps
  final int totalSteps = 7;
  Rxn<DateTime> startDate = Rxn<DateTime>(null);
  Rxn<DateTime> endDate = Rxn<DateTime>(null);
  Rxn<DateTime> checkInStartTime = Rxn<DateTime>(null);
  Rxn<DateTime> checkInEndTime = Rxn<DateTime>(null);
  Rxn<DateTime> departureDate = Rxn<DateTime>(null);
  Rxn<DateTime> arrivalDate = Rxn<DateTime>(null);

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

  Rxn<DateTime> activityStartTime = Rxn<DateTime>(null);
  Rxn<DateTime> activityEndTime = Rxn<DateTime>(null);
  Rxn<TripModel> tripModel = Rxn<TripModel>(null);
  setAllValuesToEdit() {
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
  void nextStep() {
    if (currentStep.value < totalSteps) {
      // Validate the current step's form
      if (currentStep.value == 1 && !formStep1.currentState!.validate()) {
        return;
      }
      if (selectedPlaceId.isEmpty) {
        showCustomSnackBar(content: 'Please select trip location');
        return;
      }
      if (
      // selectedImages.isEmpty ||
      (startDate.value == null || endDate.value == null)) {
        if (selectedImages.isEmpty) {
          showCustomSnackBar(content: 'Please select at least one image');
        }
        if (startDate.value == null || endDate.value == null) {
          showCustomSnackBar(content: 'Please select trip start and end date');
        }
        return;
      } else if (currentStep.value == 2 &&
          !formStep2.currentState!.validate()) {
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

  updateTrip() async {
    try {
      List<String> uploadedImages = [];
      if (selectedImages.isNotEmpty) {
        int i = 0;
        var futures = selectedImages.map((e) async {
          i++;
          if (e.isNetworkImage) {
            return e.imageUrl;
          } else {
            String imageUrl = await uploadImageToFirebaseStorage(
              imagePath: e.imageUrl,
              folderName: 'trip_images',
              title: 'Uploading trip image',
              subtitle: 'Uploading trip image',
              imageName: '${tripModel.value!.id}${Uuid().v6()}_trip_image$i',
            );
            return imageUrl;
          }
        });
        uploadedImages = await Future.wait(futures);
      }
      TripModel trip = TripModel(
        images: uploadedImages,
        tripStatus: TripStatus.upcoming.name,
        id: tripModel.value!.id,
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
        departureDate: departureDate.value ?? DateTime.now(),
        arrivalDate: arrivalDate.value ?? DateTime.now(),
        departureAirport: airportArrivalController.text,
        checkInDate: checkInStartTime.value ?? DateTime.now(),
        checkOutDate: checkInEndTime.value ?? DateTime.now(),
        country: destinationController.text.split(',').lastOrNull ?? '',
        startDate: startDate.value!,
        daysToGo: 2,
        createdBy: GlobalVariables.loggedInUser.value!.uid,
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
        LatLng latln = await GeoServices.getLatLngFromPlace(
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
              activityList[i].id = Uuid().v6();
              activityList[i].tripId = tripModel.value!.id;
              await FirebaseTripService.addActivity(activity: activityList[i]);
            }
          }
          tripModel.value!.activities = activityList;
          updateTripOverAll(tripModel.value!);
          Get.offAllNamed(
            kSpecificTripViewScreenRoute,
            arguments: tripModel.value,
          );
        } else {
          showCustomSnackBar(content: 'Failed to update trip');
        }
      });
      showCustomSnackBar(content: 'Trip updated successfully');
      GlobalVariables.showLoader.value = false;
    } catch (e) {}
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
  submitTrip() async {
    try {
      String id = Uuid().v4();
      TripModel tripModel = TripModel(
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
        daysToGo: 2,
        createdBy: GlobalVariables.loggedInUser.value!.uid,
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
      List<String> uplaodedImages = [];
      if (selectedImages.isNotEmpty) {
        int i = 0;
        var futures = selectedImages.map((e) async {
          i++;
          if (e.isNetworkImage) {
            return e.imageUrl;
          } else {
            String imageUrl = await uploadImageToFirebaseStorage(
              imagePath: e.imageUrl,
              folderName: 'trip_images',
              title: 'Uploading trip image',
              subtitle: 'Uploading trip image',
              imageName: '${'$id${Uuid().v6()}'}_trip_image$i',
            );
            return imageUrl;
          }
        });
        uplaodedImages = await Future.wait(futures);
        tripModel.images = uplaodedImages;
      }
      if (invitedUsersList.isNotEmpty) {
        // Trigger email invitations via Firebase Extension
        for (String email in invitedUsersList) {
          FirebaseFirestore.instance.collection('mail').add({
            'to': [email],
            'message': {
              'subject': 'You have been invited to a trip!',
              'text': 'You have been invited to join the trip: ${tripModel.title}. Open the Travel Crew app to accept.',
            },
          });
        }
      }
      ExpenseModel exp = ExpenseModel(
        paidByUsers: [],
        date: expanseDate.value ?? DateTime.now(),
        id: Uuid().v6(),
        createdBy: GlobalVariables.loggedInUser.value!.uid,
        tripId: tripModel.id,
        name: expenseNameController.text,
        amount: double.parse(
          amountPaidController.text.isEmpty ? '0' : amountPaidController.text,
        ),
      );
      LatLng latln = await GeoServices.getLatLngFromPlace(
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
          await FirebaseTripService.addExpenses(expense: exp).then((
            isSuccess,
          ) async {
            GlobalVariables.showLoader.value = false;
            if (isSuccess) {
              for (var i = 0; i < activityList.length; i++) {
                activityList[i].tripId = tripModel.id;
                activityList[i].id = Uuid().v6();
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

  Rxn<DateTime?> expanseDate = Rxn<DateTime?>(null);

  RxList<SearchModel> locations = RxList();
  RxList<SearchModel> hotelLocations = RxList();
  RxList<SearchModel> searchedFriends = RxList();

  void updateSearch(String value) {
    searchText.value = value;
  }

  RxInt isLoadingSuggestions = (-1).obs;

  RxList<AeroplanesModel> airlineList = RxList();
  fetchLocation(String? value, {int id = -1, String? type}) async {
    if (value == null || value.isEmpty) {
      locations.clear();
      return;
    }
    isLoadingSuggestions.value = id;
    await GeoServices.fetchPlaceSuggestions(value, type: type)
        .then((suggestions) async {
      locations.clear();
      for (var e in suggestions) {
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

  fetchHotelLocation(String? value, {int id = -1}) async {
    if (value == null || value.isEmpty) {
      hotelLocations.clear();
      return;
    }
    isLoadingSuggestions.value = id;
    await GeoServices.fetchPlaceSuggestions(value, type: 'lodging')
        .then((suggestions) async {
      hotelLocations.clear();
      for (var e in suggestions) {
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

  getLocationDetails(String value) async {
    try {
      return await GeoServices.getLocationDetailsFromPlaceId(value).then((
        location,
      ) {
        return location['result']['photos'][0]['photo_reference'];
      });
    } catch (e) {}
    return null;
  }

  fetchAeroPlanes(String? value) async {
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
      showCustomSnackBar(content: 'Failed to fetch aeroplanes');
    }
  }

  removeActivity(String? id, int index) async {
    try {
      if (id == null || id.isEmpty) {
        activityList.removeAt(index);
        activityList.refresh();
      } else {
        await FirebaseTripService.deleteActivity(id: id).then((isSuccess) {
          if (isSuccess) {
            activityList.removeAt(index);
          }
        });
      }
    } catch (e) {}
  }

  searchFriends() async {
    try {
      if (searchFriendController.text.isEmpty) {
        return;
      }
      await FirebaseTripService.searchUser(
        query: searchFriendController.text,
      ).then((users) {
        searchedFriends.clear();
        for (var e in users) {
          searchedFriends.add(
            SearchModel(
              searchText: e.displayName,
              placeId: e.uid,
              imageUrl: e.urlToImage,
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
      showCustomSnackBar(content: 'Failed to fetch friends');
    }
  }
}

class SelectedImage {
  String imageUrl;
  bool isNetworkImage;
  SelectedImage({required this.imageUrl, this.isNetworkImage = false});
}
