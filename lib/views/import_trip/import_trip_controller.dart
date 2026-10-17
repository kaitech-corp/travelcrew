import 'package:travel_crew/models/transportation_model.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/error_handler.dart';

class ImportTripController extends GetxController {
  final pasteController = TextEditingController();
  final RxBool isParsing = false.obs;

  final suggestPhoto = false.obs;

  String get selectedPrompt =>
      '$aiPrompt\n\nCover choice: ${suggestPhoto.value ? 'Suggested destination photo. If you can verify a relevant Public domain or CC0 photograph on Wikimedia Commons, include its direct HTTPS upload.wikimedia.org image URL as image_url. Otherwise omit image_url and still output the itinerary.' : 'No image. Omit image_url.'}';

  static const String aiPrompt = '''
You are helping plan a trip for TravelCrew, a group travel app. Based on our conversation, output a single JSON object matching the structure below so the app can create the trip. Output ONLY the JSON — no explanation, no markdown.

Required fields (always include these):
- "destination", "start_date", and "end_date" — the import is rejected without them. "end_date" must not be before "start_date".
- "title" and "country" — always provide these; the trip is incomplete without them.

Optional sections — include a section ONLY if you have real information for it, otherwise OMIT the whole key. Do not output empty objects, empty arrays, null, or placeholder values.

Field rules:
- Trip and expense dates use "YYYY-MM-DD". Flights and lodging may use a calendar date when the time is unknown, or an ISO 8601 local timestamp with its UTC offset when known (for example "2027-04-10T10:00:00+09:00").
- Flight departure uses the departure airport's local time and offset; arrival uses the arrival airport's local time and offset. Lodging uses the property's local time. Activity times use the activity location's local time with its offset on that date. Account for daylight saving on the event date. Use Z only when the time is actually specified in UTC; never attach Z to a local clock time. Do not invent an offset when the location or timezone is unknown; omit the time or ask for clarification.
- Every activity must have a "title". "description", "location", "address", "start_datetime", and "end_datetime" are each optional. Prefer a full street "address" when you can confidently supply it; otherwise use "location" for the venue/place name.
- Optional "transportation" is an array of up to 50 entries. Each needs "mode": "flight", "driving", "rideshare", "taxi", "train", "bus", "scooter", "bicycle", "walking", "ferry", "boat", or "other". Optional fields: "departure", "arrival", "notes". Put route, provider, driver, service/flight number, traveler names, and other details in "notes". Departure/arrival are calendar dates or local timestamps with the correct origin/destination UTC offsets. Omit unknown times. Use multiple entries for trip legs; do not repeat a flight in both "airline" and "transportation". Traveler names do not invite or grant access.
- Every expense must have a non-empty "name" and a positive "amount". "split_type" must be exactly "equally" (the only value supported on import).
- A cover image is optional. Never invent an image URL, use a placeholder, generate artwork, or supply a webpage/local file link. Only include image_url when the cover choice below requests a photo. Supported suggestions are direct Wikimedia Commons JPEG, PNG, or WebP URLs whose source page identifies the license as Public domain or CC0.\n- Numbers ("amount", "cost_per_night") must be plain JSON numbers with no currency symbol or quotes.

Strict JSON formatting requirements:
- Use only standard ASCII straight double quotes (") around every JSON key and string value.
- Do not use curly/smart quotes (“ ”), single quotes ('), or backticks (`) for JSON syntax.
- Do not include quoted text or double quotation marks inside any field value; rephrase without quotes. Keep the required straight double quotes around JSON keys and string values.
- Do not wrap the response in ```json fences.
- Do not include comments, trailing commas, or any text before or after the JSON object.
- Ensure the output can be parsed by JSON.parse/jsonDecode without cleanup.

{
  "title": "Short trip name",
  "destination": "City, Region (e.g. Tokyo, Japan)",
  "country": "Country name",
  "start_date": "YYYY-MM-DD",
  "end_date": "YYYY-MM-DD",
  "is_private": false,
  "airline": {
    "name": "Airline name",
    "flight_number": "XX123",
    "departure_airport": "IATA code (e.g. LAX)",
    "arrival_airport": "IATA code (e.g. NRT)",
    "departure_date": "YYYY-MM-DD",
    "arrival_date": "YYYY-MM-DD"
  },
  "lodging": {
    "type": "Hotel",
    "name": "Property name",
    "address": "Full street address",
    "check_in": "YYYY-MM-DD",
    "check_out": "YYYY-MM-DD",
    "cost_per_night": 0.00
  },
  "activities": [
    {
      "title": "Activity name",
      "description": "Brief description",
      "location": "Venue/place name",
      "address": "Full street address",
      "start_datetime": "YYYY-MM-DDTHH:MM:SS",
      "end_datetime": "YYYY-MM-DDTHH:MM:SS"
    }
  ],
  "expenses": [
    {
      "name": "Expense name",
      "amount": 25.00,
      "date": "YYYY-MM-DD",
      "split_type": "equally"
    }
  ]
}''';

  Future<void> copyPrompt() async {
    try {
      await Clipboard.setData(ClipboardData(text: selectedPrompt));
      // showCustomSnackBar(
      //   content: 'Prompt copied — paste it into your AI assistant',
      // );
    } catch (e, stack) {
      ErrorHandler.handleError(
        e,
        stackTrace: stack,
        context: 'ImportTrip.copyPrompt',
      );
      showCustomSnackBar(content: 'Could not copy to clipboard');
    }
  }

  void importTrip() {
    final raw = pasteController.text.trim();
    if (raw.isEmpty) {
      // showCustomSnackBar(content: 'Paste your AI response first');
      return;
    }

    isParsing.value = true;
    try {
      // Strip markdown fences and normalize all smart double quotes.
      final cleaned =
          raw
              .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
              .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
              .replaceAll(RegExp('[“”]'), '"')
              .trim();

      final data = json.decode(cleaned) as Map<String, dynamic>;

      // Validate required fields
      if ((data['destination'] as String?)?.isEmpty ?? true) {
        showCustomSnackBar(
          content: 'Destination is required — ask your AI to include it',
        );
        return;
      }
      if (data['start_date'] == null || data['end_date'] == null) {
        showCustomSnackBar(
          content:
              'Start and end dates are required — ask your AI to include them',
        );
        return;
      }
      final startDate = DateTime.tryParse(data['start_date'] as String? ?? '');
      final endDate = DateTime.tryParse(data['end_date'] as String? ?? '');
      if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
        showCustomSnackBar(content: 'Trip dates are invalid');
        return;
      }
      final transportation = data['transportation'];
      if (transportation != null) {
        if (transportation is! List || transportation.length > 50) {
          showCustomSnackBar(
            content: 'Use a list of up to 50 transportation entries.',
          );
          return;
        }
        for (final raw in transportation) {
          if (raw is! Map ||
              !TransportationMode.values.any(
                (mode) => mode.name == raw['mode'],
              )) {
            showCustomSnackBar(
              content: 'Each transportation entry needs a supported mode.',
            );
            return;
          }
          final entry = TransportationModel.fromImport(
            Map<String, dynamic>.from(raw),
            id: '',
            tripId: '',
            userId: '',
          );
          if (entry.issue != null) {
            showCustomSnackBar(content: entry.issue!);
            return;
          }
        }
      }
      final activities = data['activities'];
      if (activities is List && activities.length > 50) {
        showCustomSnackBar(content: 'Import is limited to 50 activities');
        return;
      }
      final expenses = data['expenses'];
      if (expenses is List && expenses.length > 50) {
        showCustomSnackBar(content: 'Import is limited to 50 expenses');
        return;
      }
      if (expenses is List) {
        for (final expense in expenses) {
          if (expense is! Map) continue;
          final amount = expense['amount'];
          if (amount == null || amount is! num || amount <= 0) {
            showCustomSnackBar(content: 'Expense amounts must be positive');
            return;
          }
          final date = expense['date'];
          if (date is String && DateTime.tryParse(date) == null) {
            showCustomSnackBar(content: 'Expense dates are invalid');
            return;
          }
        }
      }
      final lodging = data['lodging'];
      if (lodging is Map && lodging['cost_per_night'] != null) {
        final cost = lodging['cost_per_night'];
        if (cost is! num || cost < 0) {
          showCustomSnackBar(content: 'Lodging cost must be a positive number');
          return;
        }
      }

      final arguments = Get.arguments;
      final shouldReturnToCreate =
          arguments is Map && arguments['returnToCreate'] == true;
      if (shouldReturnToCreate) {
        Get.back(result: data);
      } else {
        Get.toNamed(kCreateTripScreenRoute, arguments: data);
      }
    } on FormatException catch (e, stack) {
      ErrorHandler.handleError(
        e,
        stackTrace: stack,
        context: 'ImportTrip.parse',
      );
      showCustomSnackBar(
        content:
            'Could not parse the response — make sure you copied the full JSON output',
      );
    } catch (e, stack) {
      ErrorHandler.handleError(
        e,
        stackTrace: stack,
        context: 'ImportTrip.importTrip',
      );
      showCustomSnackBar(
        content:
            'Something went wrong — try copying the prompt again and re-running your AI',
      );
    } finally {
      isParsing.value = false;
    }
  }

  @override
  void onClose() {
    pasteController.dispose();
    super.onClose();
  }
}
