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

  static const String aiPrompt = '''
You are helping plan a trip for TravelCrew, a group travel app. Based on our conversation, output a JSON object matching the structure below. Only include fields you have information for — omit anything unknown. Output ONLY the JSON, no explanation or markdown.

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
    "address": "Full address",
    "check_in": "YYYY-MM-DD",
    "check_out": "YYYY-MM-DD",
    "cost_per_night": 0.00
  },
  "activities": [
    {
      "title": "Activity name",
      "description": "Brief description",
      "location": "Location or address",
      "start_datetime": "YYYY-MM-DDTHH:MM:SS",
      "end_datetime": "YYYY-MM-DDTHH:MM:SS"
    }
  ]
}''';

  Future<void> copyPrompt() async {
    try {
      await Clipboard.setData(const ClipboardData(text: aiPrompt));
      showCustomSnackBar(
        content: 'Prompt copied — paste it into your AI assistant',
      );
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
      showCustomSnackBar(content: 'Paste your AI response first');
      return;
    }

    isParsing.value = true;
    try {
      // Strip markdown code fences if the AI wrapped the JSON
      final cleaned =
          raw
              .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
              .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
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
      final activities = data['activities'];
      if (activities is List && activities.length > 50) {
        showCustomSnackBar(content: 'Import is limited to 50 activities');
        return;
      }
      final lodging = data['lodging'];
      if (lodging is Map && lodging['cost_per_night'] != null) {
        final cost = lodging['cost_per_night'];
        if (cost is! num || cost < 0) {
          showCustomSnackBar(content: 'Lodging cost must be a positive number');
          return;
        }
      }

      Get.toNamed(kCreateTripScreenRoute, arguments: data);
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
