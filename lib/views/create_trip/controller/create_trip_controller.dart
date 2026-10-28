import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/utils/travel_time.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/search_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/imported_finance_expense.dart';
import 'package:travel_crew/services/finance_service.dart';
import 'package:travel_crew/services/pending_trip_import_store.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/geo_services.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/services/trip_photo_service.dart';
import 'package:travel_crew/utils/common_code.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/debugging.dart';
import 'package:uuid/uuid.dart';

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
  final suggestedPhotoUrl = ''.obs;
  final photoNotice = ''.obs;
  final isSaving = false.obs;
  int _photoSelectionVersion = 0;
  bool _allowDefaultPlacePhoto = true;
  final Map<String, dynamic> imageCredits = {};

  void chooseNoImage() {
    _allowDefaultPlacePhoto = false;
    _photoSelectionVersion++;
    suggestedPhotoUrl.value = '';
    selectedImages.clear();
    imageCredits.clear();
    photoNotice.value = '';
  }

  bool get isEditingTrip => Get.arguments is TripModel;

  void addPickedTripImages(List<String> imagePaths) {
    final images =
        imagePaths
            .where((path) => path.trim().isNotEmpty)
            .map((path) => SelectedImage(imageUrl: path))
            .toList();
    if (images.isEmpty) return;
    _photoSelectionVersion++;
    suggestedPhotoUrl.value = '';
    photoNotice.value = '';

    if (isEditingTrip && selectedImages.isNotEmpty) {
      selectedImages[0] = images.first;
      if (images.length > 1) {
        selectedImages.addAll(images.skip(1));
      }
    } else {
      selectedImages.addAll(images);
    }
    selectedImages.refresh();
  }

  Future<void> prepareSuggestedPhoto({
    Future<Map<String, dynamic>?> Function(String)? prepare,
  }) async {
    final url = suggestedPhotoUrl.value;
    if (url.isEmpty) return;
    final version = _photoSelectionVersion;
    final photo = await (prepare ?? TripPhotoService.prepare)(url);
    if (version != _photoSelectionVersion || suggestedPhotoUrl.value != url) {
      return;
    }
    if (photo == null) {
      photoNotice.value =
          'The suggested photo could not be added. Your trip can be saved without it; you can upload a photo or retry later.';
      return;
    }
    selectedImages.assignAll([
      SelectedImage(imageUrl: photo['url'] as String, isNetworkImage: true),
    ]);
    imageCredits[photo['url'] as String] = photo['credit'];
    suggestedPhotoUrl.value = '';
    photoNotice.value = '';
  }

  Future<void> usePlacePhotoAsCoverIfNeeded({
    Future<String?> Function(String)? loadPhoto,
  }) async {
    if (!_allowDefaultPlacePhoto ||
        tripModel.value != null ||
        selectedImages.isNotEmpty ||
        selectedPlaceId.value.isEmpty ||
        selectedPlaceId.value == 'existing_location') {
      return;
    }
    final version = _photoSelectionVersion;
    final place = selectedPlaceId.value;
    final photoName = await (loadPhoto ?? getLocationDetails)(place);
    if (photoName != null &&
        version == _photoSelectionVersion &&
        place == selectedPlaceId.value &&
        selectedImages.isEmpty) {
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

  // Trip data
  final tripNameController = TextEditingController();
  final destinationController = TextEditingController(),
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
      lodgingTypeController = TextEditingController();
  String? lodgingCurrencyCode;

  FocusNode destinationFocusNode = FocusNode(),
      lodgingTypeFocusNode = FocusNode(),
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
      tripNameFocusNode = FocusNode();

  Rxn<DateTime> activityStartTime = Rxn<DateTime>();
  Rxn<DateTime> activityEndTime = Rxn<DateTime>();
  Rxn<TripModel> tripModel = Rxn<TripModel>();
  final importedTransportation = <TransportationModel>[].obs;

  final List<Map<String, dynamic>> importedExpenseData = [];
  final List<String> _importedExpenseRequestIds = [];
  final Set<String> _savedExpenseRequestIds = {};
  String? importedExpenseCurrency;
  TripModel? _createdTrip;
  TripModel? _creationAttempt;
  final hasPendingCreatedTrip = false.obs;
  PendingTripImportStore pendingImportStore = PendingTripImportStore();
  Map<String, int>? _currencyOptionsCache;

  Map<String, String> _importedTimeOffsets = {};

  String? timeOffsetFor(String field) =>
      tripModel.value?.timeOffsets[field] ?? _importedTimeOffsets[field];

  Future<bool> restorePendingTrip() async {
    final ownerId = GlobalVariables.currentUid;
    if (ownerId.isEmpty) {
      throw StateError('Sign in before creating a trip.');
    }
    if (_creationAttempt != null) {
      if (_creationAttempt!.createdBy == ownerId) return true;
      _creationAttempt = null;
      _createdTrip = null;
      hasPendingCreatedTrip.value = false;
      importedTransportation.clear();
      activityList.clear();
      importedExpenseData.clear();
      _importedExpenseRequestIds.clear();
      _savedExpenseRequestIds.clear();
      importedExpenseCurrency = null;
      tripNameController.clear();
      destinationController.clear();
    }
    final pending = await pendingImportStore.load(ownerId);
    if (ownerId != GlobalVariables.currentUid) return false;
    if (pending == null) return false;
    _creationAttempt = pending.trip;
    _createdTrip = null;
    importedTransportation.assignAll(pending.transportation);
    activityList.assignAll(pending.activities);
    importedExpenseData
      ..clear()
      ..addAll(pending.expenses);
    _importedExpenseRequestIds
      ..clear()
      ..addAll(pending.expenseRequestIds);
    _savedExpenseRequestIds
      ..clear()
      ..addAll(pending.savedExpenseRequestIds);
    importedExpenseCurrency = pending.expenseCurrency;
    invitedUsersList.assignAll(pending.trip.invitedUsers ?? []);
    tripNameController.text = pending.trip.title ?? '';
    destinationController.text = pending.trip.destination;
    startDate.value = pending.trip.effectiveStartDate;
    endDate.value = pending.trip.tripEndDate;
    hasPendingCreatedTrip.value = true;
    return true;
  }

  Future<void> _persistPendingTrip() async {
    final trip = _creationAttempt;
    if (trip == null) return;
    if (trip.createdBy != GlobalVariables.currentUid) {
      throw const FormatException(
        'Sign in to the trip owner account to retry.',
      );
    }
    await pendingImportStore.save(
      PendingTripImport(
        trip: trip,
        transportation: importedTransportation.toList(),
        activities: activityList.toList(),
        expenses: importedExpenseData.toList(),
        expenseRequestIds: _importedExpenseRequestIds.toList(),
        savedExpenseRequestIds: _savedExpenseRequestIds.toSet(),
        expenseCurrency: importedExpenseCurrency,
      ),
    );
  }

  void setFromImport(Map<String, dynamic> data) {
    if (_createdTrip != null || _creationAttempt != null) {
      showCustomSnackBar(
        content: 'Finish saving this trip before importing another itinerary.',
      );
      return;
    }
    _importedTimeOffsets = {};
    _allowDefaultPlacePhoto = false;
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

      // Never render arbitrary model-provided URLs on a user's device.
      if (data['image_url'] is String &&
          (data['image_url'] as String).trim().isNotEmpty) {
        _photoSelectionVersion++;
        suggestedPhotoUrl.value = (data['image_url'] as String).trim();
        photoNotice.value = '';
      }

      final transport = data['transportation'] as List? ?? [];
      if (transport.length > 50) {
        throw const FormatException(
          'Import is limited to 50 transportation entries.',
        );
      }
      importedTransportation.assignAll(
        transport.map((raw) {
          final values = Map<String, dynamic>.from(raw as Map);
          if (!TransportationMode.values.any(
            (mode) => mode.name == values['mode'],
          )) {
            throw const FormatException(
              'Choose a supported transportation mode.',
            );
          }
          final entry = TransportationModel.fromImport(
            values,
            id: const Uuid().v4(),
            tripId: '',
            userId: GlobalVariables.currentUid,
          );
          if (entry.issue != null) throw FormatException(entry.issue!);
          return entry;
        }),
      );
      _applyLodgingImport(data['lodging']);
      _applyActivitiesImport(data['activities']);
      _applyExpensesImport(data['expenses'], data['expense_currency']);
    } catch (e, stack) {
      kLogging('setFromImport error: $e\n$stack');
      showCustomSnackBar(
        content:
            'Some fields could not be imported — please fill them in manually',
      );
    }
  }

  void _applyLodgingImport(dynamic raw) {
    if (raw is! Map<String, dynamic>) return;
    lodgingCurrencyCode = null;
    lodgingTypeController.text = (raw['type'] as String?) ?? '';
    hotelNameController.text = (raw['name'] as String?) ?? '';
    addressController.text = (raw['address'] as String?) ?? '';
    if (raw['check_in'] != null) {
      final zone = TravelTime.offset(raw['check_in'] as String);
      if (zone != null) _importedTimeOffsets['checkInDate'] = zone;
      checkInStartTime.value = TravelTime.tryParse(raw['check_in'] as String);
    }
    if (raw['check_out'] != null) {
      final zone = TravelTime.offset(raw['check_out'] as String);
      if (zone != null) _importedTimeOffsets['checkOutDate'] = zone;
      checkInEndTime.value = TravelTime.tryParse(raw['check_out'] as String);
    }
    if (raw['cost_per_night'] != null) {
      final currency = raw['cost_currency'];
      if (currency is! String || !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
        throw const FormatException(
          'A lodging nightly cost needs cost_currency.',
        );
      }
      expensePerNightController.text =
          (raw['cost_per_night'] as num).toString();
      lodgingCurrencyCode = currency;
    }
  }

  void _applyActivitiesImport(dynamic raw) {
    if (raw is! List) return;
    activityList.value =
        raw
            .whereType<Map<String, dynamic>>()
            .map(
              (act) => ActivityModel(
                createdBy: GlobalVariables.currentUid,
                timeOffsets: TravelTime.offsets(
                  {
                    'startDateTime': act['start_datetime'],
                    'endDateTime': act['end_datetime'],
                  },
                  ['startDateTime', 'endDateTime'],
                ),
                title: (act['title'] as String?) ?? '',
                description: (act['description'] as String?) ?? '',
                location:
                    ((act['address'] as String?)?.trim().isNotEmpty ?? false)
                        ? act['address'] as String
                        : act['location'] as String?,
                startDateTime:
                    act['start_datetime'] != null
                        ? TravelTime.tryParse(act['start_datetime'] as String)
                        : null,
                endDateTime:
                    act['end_datetime'] != null
                        ? TravelTime.tryParse(act['end_datetime'] as String)
                        : null,
                tripId: '',
                likesCount: 0,
              ),
            )
            .toList();
  }

  void _applyExpensesImport(dynamic raw, dynamic currency) {
    importedExpenseData.clear();
    _importedExpenseRequestIds.clear();
    _savedExpenseRequestIds.clear();
    _currencyOptionsCache = null;
    importedExpenseCurrency = null;
    if (raw == null) return;
    if (raw is! List ||
        raw.length > 50 ||
        raw.any((item) => item is! Map<String, dynamic>)) {
      throw const FormatException('Import is limited to 50 valid expenses.');
    }
    if (raw.isEmpty) return;
    if (currency is! String || !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      throw const FormatException('Choose one currency for imported expenses.');
    }
    importedExpenseCurrency = currency;
    for (final item in raw) {
      importedExpenseData.add(Map<String, dynamic>.from(item as Map));
      _importedExpenseRequestIds.add(const Uuid().v4());
    }
  }

  Future<List<ImportedFinanceExpense>> buildImportedFinanceExpenses({
    Map<String, int>? currencyOptions,
  }) async {
    if (importedExpenseData.isEmpty) return [];
    final options =
        currencyOptions ??
        (_currencyOptionsCache ??= await FinanceService.getCurrencyOptions());
    final currency = importedExpenseCurrency;
    final precision = options[currency];
    if (currency == null || precision == null) {
      throw const FormatException(
        'Choose a supported currency for imported expenses.',
      );
    }
    return [
      for (var index = 0; index < importedExpenseData.length; index++)
        ImportedFinanceExpense.fromMap(
          importedExpenseData[index],
          currencyCode: currency,
          precision: precision,
          requestId: _importedExpenseRequestIds[index],
        ),
    ];
  }

  Future<void> saveImportedFinanceExpenses(
    List<ImportedFinanceExpense> drafts, {
    required String tripId,
    required String ownerId,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>)? save,
  }) async {
    final saveExpense = save ?? FinanceService.saveExpense;
    for (final draft in drafts) {
      if (_savedExpenseRequestIds.contains(draft.requestId)) continue;
      await saveExpense(draft.requestFor(tripId, ownerId));
      _savedExpenseRequestIds.add(draft.requestId);
      await _persistPendingTrip();
    }
  }

  void prepareImportedActivityIds(String tripId) {
    for (final activity in activityList) {
      activity.tripId = tripId;
      if (activity.createdBy.isEmpty) {
        activity.createdBy = GlobalVariables.currentUid;
      }
      if (activity.id == null || activity.id!.isEmpty) {
        activity.id = const Uuid().v6();
      }
    }
  }

  Future<void> saveImportedActivities({
    Future<bool> Function(ActivityModel)? save,
  }) async {
    final write =
        save ??
        (activity) => FirebaseTripService.addActivity(activity: activity);
    for (final activity in activityList) {
      if (activity.id == null ||
          activity.id!.isEmpty ||
          activity.tripId.isEmpty) {
        throw const FormatException('Activity retry identity is missing.');
      }
      if (!await write(activity)) {
        throw StateError(
          'An activity could not be saved. Tap Finish Trip to retry.',
        );
      }
    }
  }

  Future<void> ensureCreatedTrip(
    TripModel draft, {
    bool checkBeforeCreate = true,
    Future<bool> Function(String tripId, String ownerId)? exists,
    Future<bool> Function(TripModel trip)? create,
  }) async {
    final check =
        exists ??
        (tripId, ownerId) => FirebaseTripService.createdTripExists(
          tripId: tripId,
          ownerId: ownerId,
        );
    final write =
        create ??
        (trip) => FirebaseTripService.addTrip(
          tripModel: trip,
          transportation: importedTransportation.toList(),
        );
    if (!checkBeforeCreate || !await check(draft.id, draft.createdBy)) {
      final saved = await write(draft);
      if (!saved && !await check(draft.id, draft.createdBy)) {
        throw const FormatException(
          'Could not create trip. Your itinerary is still here; retry.',
        );
      }
    }
    _createdTrip = draft;
    hasPendingCreatedTrip.value = true;
  }

  void setAllValuesToEdit() {
    tripNameController.text = tripModel.value!.title ?? '';
    country.value = tripModel.value!.country;
    destinationController.text = tripModel.value!.tripLocation ?? '';
    hotelNameController.text = tripModel.value!.hotelName ?? '';
    addressController.text = tripModel.value!.hotelAddress ?? '';
    invitedUsersList.value = tripModel.value!.invitedUsers ?? [];
    selectedLocation.value = tripModel.value!.tripLocation ?? '';
    // Set selectedPlaceId to a non-empty value when editing to bypass location validation
    selectedPlaceId.value = 'existing_location';
    expensePerNightController.text =
        tripModel.value!.expensePerNight?.toString() ?? '';
    lodgingCurrencyCode = tripModel.value!.lodgingCurrencyCode;
    startDate.value = tripModel.value!.effectiveStartDate;
    endDate.value =
        tripModel.value!.tripEndDate ??
        DateTime.tryParse(tripModel.value!.endDate);
    checkInStartTime.value = tripModel.value!.checkInDate;
    checkInEndTime.value = tripModel.value!.checkOutDate;
    selectedImages.value =
        (tripModel.value?.images ?? []).map((e) {
          return SelectedImage(imageUrl: e, isNetworkImage: true);
        }).toList();
    suggestedPhotoUrl.value = '';
    imageCredits
      ..clear()
      ..addAll(tripModel.value!.imageCredits);
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

  double? get optionalNightlyCost {
    final text = expensePerNightController.text.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value < 0) {
      throw const FormatException(
        'Enter a valid non-negative lodging price, or leave it blank.',
      );
    }
    if (lodgingCurrencyCode == null &&
        tripModel.value?.expensePerNight != value) {
      throw const FormatException(
        'Set cost_currency for the lodging nightly rate.',
      );
    }
    if (lodgingCurrencyCode != null &&
        !RegExp(r'^[A-Z]{3}$').hasMatch(lodgingCurrencyCode!)) {
      throw const FormatException('Use a three-letter lodging currency code.');
    }
    return value;
  }

  /// Only changed editor fields are written. Server-owned fields, membership,
  /// counters and unrelated itinerary data are never rebuilt by this form.
  Map<String, dynamic> buildTripUpdate(List<String> images) {
    final original = tripModel.value!;
    final previous = original.toMap();
    String? optionalText(String value) =>
        value.trim().isEmpty ? null : value.trim();
    final candidate = <String, dynamic>{
      'title': tripNameController.text.trim(),
      'destination': destinationController.text.trim(),
      'tripLocation': destinationController.text.trim(),
      'country': country.value,
      'tripStartDate': startDate.value!.toIso8601String(),
      'tripEndDate': endDate.value!.toIso8601String(),
      'isPrivate': isLocked.value,
      'checkInDate': TravelTime.serialize(
        checkInStartTime.value,
        original.timeOffsets['checkInDate'],
      ),
      'checkOutDate': TravelTime.serialize(
        checkInEndTime.value,
        original.timeOffsets['checkOutDate'],
      ),
      'hotelName': optionalText(hotelNameController.text),
      'hotelAddress': optionalText(addressController.text),
      'lodgingType': optionalText(lodgingTypeController.text),
      'expensePerNight': optionalNightlyCost,
      'lodgingCurrencyCode':
          optionalNightlyCost == null ? null : lodgingCurrencyCode,
    };
    final patch = <String, dynamic>{};
    for (final entry in candidate.entries) {
      if (entry.value != previous[entry.key] &&
          !(entry.value == null && previous[entry.key] == '')) {
        patch[entry.key] = entry.value;
      }
    }
    if (patch.containsKey('tripStartDate')) {
      patch['startDate'] = startDate.value!.toIso8601String();
      patch['daysToGo'] = _calendarDaysUntil(startDate.value!);
    }
    if (patch.containsKey('tripEndDate')) {
      patch['endDate'] = endDate.value!.toIso8601String().split('T').first;
    }
    if (!listEquals(images, original.images)) {
      patch['images'] = images;
      patch['imageCredits'] = {
        for (final url in images)
          if (imageCredits.containsKey(url)) url: imageCredits[url],
      };
    }
    return patch;
  }

  Future<List<String>> _uploadSelectedImages(String tripId) async {
    final uploaded = <String>[];
    // Replace successful uploads in-place, so a failed save can be retried
    // without uploading the same file again.
    for (final image in selectedImages.toList()) {
      if (!image.isNetworkImage) {
        final url = await uploadImageToFirebaseStorage(
          imagePath: image.imageUrl,
          folderName: 'trip_images',
          tripId: tripId,
          title: 'Uploading trip image',
          subtitle: 'Uploading trip image',
          imageName: '${tripId}_${const Uuid().v4()}_trip_image',
        );
        if (url.isEmpty) throw StateError('Image upload failed');
        image.imageUrl = url;
        image.isNetworkImage = true;
      }
      uploaded.add(image.imageUrl);
    }
    selectedImages.refresh();
    return uploaded;
  }

  /// Assistant/MCP-created trips are saved without coordinates. Treat the
  /// 0,0 placeholder as unknown rather than as a real location.
  bool get hasKnownCoordinates {
    final trip = tripModel.value;
    return trip != null && !(trip.latitude == 0 && trip.longitude == 0);
  }

  bool get _hasSelectedPlace =>
      selectedPlaceId.value.isNotEmpty &&
      selectedPlaceId.value != 'existing_location';

  /// A public trip is listed in discovery and Nearby by its coordinates, so a
  /// trip without a known location must not be published until the owner
  /// selects one. Private trips may keep an unknown location.
  String? publicLocationIssue() {
    if (isLocked.value || hasKnownCoordinates || _hasSelectedPlace) return null;
    return 'Select the trip location before making this trip public.';
  }

  Future<void> updateTrip() async {
    if (isSaving.value) return;
    isSaving.value = true;
    GlobalVariables.showLoader.value = true;
    try {
      // Validate before uploads or other network requests.
      buildTripUpdate(selectedImages.map((image) => image.imageUrl).toList());
      final locationIssue = publicLocationIssue();
      if (locationIssue != null) {
        showCustomSnackBar(content: locationIssue);
        return;
      }
      final original = tripModel.value!;
      await prepareSuggestedPhoto();
      final images = await _uploadSelectedImages(original.id);
      final patch = buildTripUpdate(images);
      // Re-selecting the same destination text still needs a coordinate
      // lookup when the trip has none.
      if (patch.containsKey('tripLocation') ||
          (_hasSelectedPlace && !hasKnownCoordinates)) {
        final location = await GeoServices.getLatLngFromPlace(
          destinationController.text,
          placeId: selectedPlaceId.value,
        );
        patch['latitude'] = location.latitude;
        patch['longitude'] = location.longitude;
        patch['continent'] = CommonCode.getContinentFromLatLng(
          location.latitude,
          location.longitude,
        );
      }
      final saved = await FirebaseTripService.updateTrip(
        tripId: original.id,
        data: patch,
        expectedEditedFields: original.toMap(),
        expectedImages: patch.containsKey('images') ? original.images : null,
        expectedLodging:
            patch.keys.any(
                  const {
                    'lodgingType',
                    'hotelName',
                    'hotelAddress',
                    'checkInDate',
                    'checkOutDate',
                    'expensePerNight',
                    'lodgingCurrencyCode',
                  }.contains,
                )
                ? original
                : null,
      );
      if (!saved) {
        showCustomSnackBar(
          content:
              'Could not save changes. Your edits are still here. Retry, or reopen the trip if it changed on another device.',
        );
        return;
      }
      // The core save has committed even if a later activity save fails.
      // Advance the comparison baseline so a retry does not conflict with
      // this editor's own newly saved cover.
      final committed = TripModel.fromMap({
        ...original.toMap(),
        'tripBudget': original.tripBudget,
        ...patch,
      });
      committed.expenses = original.expenses;
      committed.joindUsersList = original.joindUsersList;
      committed.createdByUser = original.createdByUser;
      tripModel.value = committed;
      updateTripOverAll(committed);
      for (final activity in activityList) {
        if (activity.id == null) {
          activity.id = const Uuid().v4();
          activity.tripId = original.id;
          if (!await FirebaseTripService.addActivity(activity: activity)) {
            activity.id = null;
            showCustomSnackBar(
              content:
                  'Trip saved, but an activity could not be saved. Retry to add it.',
            );
            return;
          }
        }
      }
      TripModel? updated;
      try {
        updated = await FirebaseTripService.getTripById(tripId: original.id);
      } catch (error) {
        if (kDebugMode) print('Trip saved but refresh failed: $error');
        showCustomSnackBar(
          content: 'Trip saved, but details could not refresh. Reopen it.',
        );
        return;
      }
      if (updated == null) {
        showCustomSnackBar(
          content: 'Trip saved, but it is no longer available.',
        );
        return;
      }
      updated.activities = activityList.toList();
      updated.expenses ??= original.expenses;
      updated.joindUsersList ??= original.joindUsersList;
      updated.createdByUser ??= original.createdByUser;
      tripModel.value = updated;
      updateTripOverAll(updated);
      Get.offNamed(kSpecificTripViewScreenRoute, arguments: updated);
      if (photoNotice.isNotEmpty) {
        showCustomSnackBar(content: photoNotice.value);
      }
    } on FormatException catch (error) {
      showCustomSnackBar(content: error.message);
    } catch (error) {
      if (kDebugMode) print('Error in updateTrip: $error');
      showCustomSnackBar(
        content:
            'Could not save the trip. Your edits are still here; please retry.',
      );
    } finally {
      isSaving.value = false;
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
    if (isSaving.value) {
      showCustomSnackBar(content: 'Please wait for this trip save to finish.');
      return;
    }
    if (_createdTrip != null || _creationAttempt != null) {
      Get.dialog<void>(
        AlertDialog(
          title: const Text('Leave unfinished trip save?'),
          content: const Text(
            'The trip may have been created, but some imported details have not all saved. Retry now to finish, or review it later in My Trips.',
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Stay')),
            TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      );
      return;
    }
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      // Go back to previous screen
      Get.back();
    }
  }

  // Submit the trip
  Future<void> submitTrip() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final expensesToSave = await buildImportedFinanceExpenses();
      GlobalVariables.showLoader.value = true;
      TripModel created;
      var firstCreateAttempt = false;
      if (_createdTrip == null && _creationAttempt == null) {
        final nightlyCost = optionalNightlyCost;
        final id = const Uuid().v4();
        created = TripModel(
          timeOffsets: Map.of(_importedTimeOffsets),
          tripStatus: TripStatus.upcoming.name,
          id: id,
          tripLocation: destinationController.text,
          invitedUsers: invitedUsersList.isEmpty ? [] : invitedUsersList,
          joinedUsers: [],
          isPrivate: isLocked.value,
          checkInDate: checkInStartTime.value,
          checkOutDate: checkInEndTime.value,
          country: country.value,
          startDate: startDate.value!,
          daysToGo: _calendarDaysUntil(startDate.value!),
          createdBy: GlobalVariables.currentUid,
          title: tripNameController.text,
          destination: destinationController.text,
          tripStartDate: startDate.value!,
          tripEndDate: endDate.value!,
          endDate: '',
          hotelName: hotelNameController.text,
          hotelAddress: addressController.text,
          expensePerNight: nightlyCost,
          lodgingCurrencyCode: nightlyCost == null ? null : lodgingCurrencyCode,
          lodgingType: lodgingTypeController.text,
          images: [],
        );
        await prepareSuggestedPhoto();
        await usePlacePhotoAsCoverIfNeeded();
        created.images = await _uploadSelectedImages(id);
        created.imageCredits.addAll(imageCredits);
        final location = await GeoServices.getLatLngFromPlace(
          created.tripLocation ?? '',
        );
        created.latitude = location.latitude;
        created.longitude = location.longitude;
        created.continent = CommonCode.getContinentFromLatLng(
          created.latitude,
          created.longitude,
        );
        _creationAttempt = created;
        hasPendingCreatedTrip.value = true;
        firstCreateAttempt = true;
      }
      if (_createdTrip == null) {
        created = _creationAttempt!;
        prepareImportedActivityIds(created.id);
        await _persistPendingTrip();
        await ensureCreatedTrip(
          created,
          checkBeforeCreate: !firstCreateAttempt,
        );
      } else {
        created = _createdTrip!;
        prepareImportedActivityIds(created.id);
        await _persistPendingTrip();
      }

      await saveImportedFinanceExpenses(
        expensesToSave,
        tripId: created.id,
        ownerId: created.createdBy,
      );

      await saveImportedActivities();
      TripModel? hydrated;
      try {
        hydrated = await FirebaseTripService.getTripById(tripId: created.id);
      } catch (error) {
        if (kDebugMode) print('Created trip refresh failed: $error');
        showCustomSnackBar(
          content:
              'Trip saved, but details could not load. Retry to finish opening it.',
        );
        return;
      }
      if (hydrated == null) {
        showCustomSnackBar(
          content: 'Trip saved, but it is no longer available.',
        );
        return;
      }
      final shown = hydrated;
      shown.activities = activityList.toList();
      await pendingImportStore.delete(created.createdBy);
      addTripOverAll(shown);
      GlobalVariables.showLoader.value = false;
      Get.offNamed(kSpecificTripViewScreenRoute, arguments: shown);
      if (photoNotice.isNotEmpty) {
        showCustomSnackBar(content: photoNotice.value);
      }

      try {
        final sent = await FirebaseTripService.sendTripInvites(
          tripId: created.id,
          tripTitle: created.title ?? created.destination,
          emails: created.invitedUsers ?? const [],
          requestId: 'initial_${created.id}',
        );
        if (!sent) {
          showCustomSnackBar(
            content:
                'Trip saved, but invitations could not be sent. Retry from the trip.',
          );
        }
      } catch (error) {
        showCustomSnackBar(
          content:
              'Trip saved, but invitations could not be sent. Retry from the trip.',
        );
        if (kDebugMode) print('Trip invitation failure: $error');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in submitTrip: $e');
      }
      showCustomSnackBar(
        content:
            _creationAttempt == null
                ? e.toString()
                : 'Trip save is unfinished. Retry to check the original trip and save pending expenses. $e',
        contentType: ContentType.failure,
      );
    } finally {
      isSaving.value = false;
      GlobalVariables.showLoader.value = false;
    }
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

  Future<void> removeActivity(String? id, int index) async {
    try {
      if (id == null || id.isEmpty) {
        activityList.removeAt(index);
        activityList.refresh();
      } else {
        await FirebaseTripService.deleteActivity(
          id: id,
          tripId: activityList[index].isLegacy ? null : tripModel.value?.id,
          expectedRevision: activityList[index].contentRevision,
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
        for (final e in users.where((user) => !SafetyService.hides(user.uid))) {
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

    destinationFocusNode.dispose();
    lodgingTypeFocusNode.dispose();
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
    super.onClose();
  }
}

class SelectedImage {
  SelectedImage({required this.imageUrl, this.isNetworkImage = false});
  String imageUrl;
  bool isNetworkImage;
}
