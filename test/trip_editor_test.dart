import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/views/create_trip/create_trip_screen.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/custom_widgets/custom_elevated_button.dart';
import 'package:travel_crew/views/import_trip/import_trip_controller.dart';

const suggestedUrl =
    'https://upload.wikimedia.org/wikipedia/commons/a/ab/Tokyo.jpg';

class SaveProbeController extends CreateTripController {
  int saves = 0;
  @override
  Future<void> updateTrip() async {
    saves++;
  }
}

CreateTripController editor({
  List<String> images = const [],
  double? price,
  double latitude = 35.6,
  double longitude = 139.7,
}) {
  final controller = CreateTripController();
  controller.tripModel.value = TripModel.fromMap({
    'id': '09e04f90-1acd-4f38-828f-32a359cc25e1',
    'createdBy': 'owner',
    'title': 'Tokyo',
    'destination': 'Tokyo',
    'tripLocation': 'Tokyo',
    'country': 'Japan',
    'tripStartDate': '2027-04-10T00:00:00.000',
    'tripEndDate': '2027-04-12T00:00:00.000',
    'startDate': '2027-04-10T00:00:00.000',
    'endDate': '2027-04-12',
    'isPrivate': true,
    'isShared': false,
    'joinedUsers': ['member'],
    'invitedUsers': ['friend@example.com'],
    'images': images,
    'expensePerNight': price,
    'latitude': latitude,
    'longitude': longitude,
    'continent': 'Asia',
    'tripBudget': 500,
    'favouriteCount': 8,
    'activities': [
      {'id': 'existing', 'tripId': 'trip', 'title': 'Museum'},
    ],
    'imageCredits': {
      for (final image in images) image: {'license': 'CC0'},
    },
  });
  controller.setAllValuesToEdit();
  addTearDown(controller.onClose);
  return controller;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'TRAVEL_CREW_WEB_BASE_URL=https://travelcrew.app',
    ),
  );
  test(
    'trip edit conflict check sees changed fields and preserves unrelated edits',
    () {
      final trip = editor().tripModel.value!;
      final expected = trip.toMap();
      final current = {...expected, 'favouriteCount': 9, 'title': 'Other edit'};
      expect(
        changedTripUpdateFields(
          current: current,
          expected: expected,
          fields: ['destination'],
          tripId: trip.id,
        ),
        isEmpty,
      );
      expect(
        changedTripUpdateFields(
          current: current,
          expected: expected,
          fields: ['title'],
          tripId: trip.id,
        ),
        ['title'],
      );
      expect(
        changedTripUpdateFields(
          current: {...current, 'futureEditorField': 'changed'},
          expected: {...expected, 'futureEditorField': 'original'},
          fields: ['futureEditorField'],
          tripId: trip.id,
        ),
        ['futureEditorField'],
      );
    },
  );
  test(
    'trip edit conflict check handles old optional fields and nested cover credits',
    () {
      final trip =
          editor(images: ['https://example.com/cover.jpg']).tripModel.value!;
      final expected = trip.toMap();
      final withoutOptional = {...expected}..remove('lodgingCurrencyCode');
      expect(
        changedTripUpdateFields(
          current: withoutOptional,
          expected: expected,
          fields: ['lodgingCurrencyCode'],
          tripId: trip.id,
        ),
        isEmpty,
      );
      final changedCredit = {
        ...expected,
        'imageCredits': {
          'https://example.com/cover.jpg': {'license': 'CC BY'},
        },
      };
      expect(
        changedTripUpdateFields(
          current: changedCredit,
          expected: expected,
          fields: ['imageCredits'],
          tripId: trip.id,
        ),
        ['imageCredits'],
      );
    },
  );
  testWidgets('the edit screen lets an image-free MCP trip reach save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    GoogleFonts.config.allowRuntimeFetching = false;
    Get.testMode = true;
    final controller = SaveProbeController();
    Get.put<CreateTripController>(controller);
    addTearDown(Get.reset);
    final trip = editor().tripModel.value!;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (_, _) => GetMaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(),
              getPages: [
                GetPage(name: '/edit', page: () => const CreateTripScreen()),
              ],
            ),
      ),
    );
    Get.toNamed('/edit', arguments: trip);
    await tester.pumpAndSettle();
    controller.tripNameController.text = 'Renamed from app';
    await tester.tap(find.byType(CustomElevatedButton));
    await tester.pumpAndSettle();
    expect(controller.selectedImages, isEmpty);
    expect(controller.saves, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  test(
    'native creation retains its Places default; imports and No image opt out',
    () async {
      for (final mode in ['native', 'import', 'none', 'edit']) {
        final controller = mode == 'edit' ? editor() : CreateTripController();
        if (mode != 'edit') addTearDown(controller.onClose);
        if (mode == 'import') {
          controller.setFromImport({'destination': 'Tokyo'});
        }
        if (mode == 'none') controller.chooseNoImage();
        controller.selectedPlaceId.value = 'real-place';
        var requested = false;
        await controller.usePlacePhotoAsCoverIfNeeded(
          loadPhoto: (_) async {
            requested = true;
            return 'places/real-place/photos/photo';
          },
        );
        expect(requested, mode == 'native');
        expect(controller.selectedImages.length, mode == 'native' ? 1 : 0);
      }
    },
  );
  test('new trips default to private; imports only go public explicitly', () {
    final fresh = CreateTripController();
    addTearDown(fresh.onClose);
    expect(fresh.isLocked.value, isTrue);

    final imported = CreateTripController();
    addTearDown(imported.onClose);
    imported.setFromImport({'destination': 'Tokyo'});
    expect(imported.isLocked.value, isTrue);

    final public = CreateTripController();
    addTearDown(public.onClose);
    public.setFromImport({'destination': 'Tokyo', 'is_private': false});
    expect(public.isLocked.value, isFalse);
  });
  test('a late Places response cannot override explicit No image', () async {
    final controller = CreateTripController();
    addTearDown(controller.onClose);
    controller.selectedPlaceId.value = 'real-place';
    final response = Completer<String?>();
    final pending = controller.usePlacePhotoAsCoverIfNeeded(
      loadPhoto: (_) => response.future,
    );
    controller.chooseNoImage();
    response.complete('places/real-place/photos/photo');
    await pending;
    expect(controller.selectedImages, isEmpty);
  });
  test(
    'rename an image-free MCP trip without altering any other stored field',
    () {
      final controller = editor();
      expect(controller.expensePerNightController.text, '');
      controller.tripNameController.text = 'Tokyo holiday';
      expect(controller.buildTripUpdate([]), {'title': 'Tokyo holiday'});
    },
  );
  test(
    'adding first cover with no lodging cost succeeds and preserves absent travel dates',
    () {
      final controller = editor();
      controller.addPickedTripImages(['/tmp/new-cover.jpg']);
      final patch = controller.buildTripUpdate([
        'https://storage.example/cover.jpg',
      ]);
      expect(patch, {
        'images': ['https://storage.example/cover.jpg'],
        'imageCredits': {},
      });
      final merged = TripModel.fromMap({
        ...controller.tripModel.value!.toMap(),
        'tripBudget': controller.tripModel.value!.tripBudget,
        ...patch,
      });
      expect(merged.expensePerNight, isNull);
      expect(merged.checkInDate, isNull);
      expect(merged.country, 'Japan');
      expect(merged.latitude, 35.6);
      expect(merged.joinedUsers, ['member']);
      expect(merged.favouriteCount, 8);
      expect(merged.tripBudget, 500);
      expect(merged.activities!.single.title, 'Museum');
    },
  );
  test(
    'blank price is nullable, zero remains zero and invalid values never become zero',
    () {
      final controller = editor(price: 42);
      expect(controller.buildTripUpdate([]), isEmpty);
      controller.expensePerNightController.text = '';
      expect(controller.buildTripUpdate([])['expensePerNight'], isNull);
      expect(
        controller.buildTripUpdate([]).containsKey('expensePerNight'),
        isTrue,
      );
      controller.expensePerNightController.text = '0';
      controller.lodgingCurrencyCode = 'USD';
      expect(controller.optionalNightlyCost, 0);
      for (final bad in ['null', 'NaN', 'Infinity', '-1', 'abc']) {
        controller.expensePerNightController.text = bad;
        expect(() => controller.buildTripUpdate([]), throwsFormatException);
      }
    },
  );
  test(
    'no-image selection removes images and obsolete credit but no other data',
    () {
      final controller = editor(images: ['https://existing.example/cover.jpg']);
      controller.chooseNoImage();
      expect(controller.buildTripUpdate([]), {
        'images': <String>[],
        'imageCredits': {},
      });
    },
  );
  test(
    'imported suggestion is not rendered until verified and failure does not block the trip',
    () async {
      final controller = editor();
      controller.setFromImport({
        'title': 'Tokyo',
        'destination': 'Tokyo',
        'country': 'Japan',
        'image_url': suggestedUrl,
      });
      expect(controller.selectedImages, isEmpty);
      await controller.prepareSuggestedPhoto(prepare: (_) async => null);
      expect(controller.selectedImages, isEmpty);
      expect(controller.photoNotice.value, contains('could not be added'));
      expect(
        controller.suggestedPhotoUrl.value,
        suggestedUrl,
        reason: 'Keep failed suggestion for retry',
      );
      expect(controller.buildTripUpdate([])['expensePerNight'], isNull);
    },
  );
  test('verified photo and its attribution are used together', () async {
    final controller = editor();
    controller.suggestedPhotoUrl.value = suggestedUrl;
    await controller.prepareSuggestedPhoto(
      prepare:
          (_) async => {
            'url': 'https://storage.example/verified.jpg',
            'credit': {'license': 'CC0', 'author': 'Photographer'},
          },
    );
    expect(
      controller.selectedImages.single.imageUrl,
      'https://storage.example/verified.jpg',
    );
    expect(
      controller.buildTripUpdate([
        controller.selectedImages.single.imageUrl,
      ])['imageCredits'],
      {
        'https://storage.example/verified.jpg': {
          'license': 'CC0',
          'author': 'Photographer',
        },
      },
    );
  });
  test(
    'late preparation cannot replace No image or a newer manual photo',
    () async {
      for (final noImage in [true, false]) {
        final controller = editor();
        controller.suggestedPhotoUrl.value = suggestedUrl;
        final completion = Completer<Map<String, dynamic>?>();
        final pending = controller.prepareSuggestedPhoto(
          prepare: (_) => completion.future,
        );
        if (noImage) {
          controller.chooseNoImage();
        } else {
          controller.addPickedTripImages(['/tmp/my-photo.jpg']);
        }
        completion.complete({
          'url': 'https://storage.example/stale.jpg',
          'credit': {'license': 'CC0'},
        });
        await pending;
        expect(
          controller.selectedImages.map((e) => e.imageUrl).toList(),
          noImage ? [] : ['/tmp/my-photo.jpg'],
        );
        expect(controller.imageCredits, isEmpty);
      }
    },
  );
  test(
    'copy prompt offers only no image or verified suggested photo, without placeholder URL',
    () {
      final controller = ImportTripController();
      addTearDown(controller.onClose);
      expect(controller.selectedPrompt, contains('No image. Omit image_url.'));
      expect(
        controller.selectedPrompt,
        isNot(contains('https://example.com/photo.jpg')),
      );
      controller.suggestPhoto.value = true;
      expect(
        controller.selectedPrompt,
        contains('Suggested destination photo.'),
      );
      expect(controller.selectedPrompt, contains('Otherwise omit image_url'));
      expect(controller.selectedPrompt, contains('Never invent an image URL'));
    },
  );

  test(
    'publishing a trip without coordinates requires a selected location',
    () {
      final located = editor();
      located.isLocked.value = false;
      expect(located.publicLocationIssue(), isNull);

      final imported = editor(latitude: 0, longitude: 0);
      expect(imported.hasKnownCoordinates, isFalse);
      expect(
        imported.publicLocationIssue(),
        isNull,
        reason: 'A private trip may keep an unknown location',
      );
      imported.isLocked.value = false;
      expect(imported.publicLocationIssue(), isNotNull);
      imported.selectedPlaceId.value = 'real-place';
      expect(imported.publicLocationIssue(), isNull);
    },
  );
}
