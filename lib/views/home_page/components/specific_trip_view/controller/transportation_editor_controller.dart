import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:uuid/uuid.dart';

class TransportationDateController {
  TransportationDateController(String? value) {
    if (value != null && value.length >= 10) date.text = value.substring(0, 10);
    if (value != null && value.length >= 16) {
      time.text = value.substring(11, 16);
    }
  }
  final date = TextEditingController();
  final time = TextEditingController();

  String? get value {
    if (date.text.trim().isEmpty) return null;
    if (time.text.trim().isEmpty) return date.text.trim();
    return '${date.text.trim()}T${time.text.trim()}:00';
  }

  String? get issue {
    if (time.text.isNotEmpty && date.text.isEmpty) {
      return 'Choose a date for this time.';
    }
    return TransportationModel.dateIssue(value);
  }

  void dispose() {
    date.dispose();
    time.dispose();
  }
}

class TransportationEditorController extends GetxController {
  TransportationEditorController({
    this.existing,
    required this.tripId,
    required this.userId,
    this.displayName = '',
  }) {
    mode.value = existing?.mode ?? TransportationMode.driving;
    notes.text = existing?.notes ?? '';
    departure = TransportationDateController(existing?.departure);
    arrival = TransportationDateController(existing?.arrival);
  }
  final TransportationModel? existing;
  final String tripId, userId, displayName;
  final mode = TransportationMode.driving.obs;
  final notes = TextEditingController();
  late final TransportationDateController departure, arrival;
  final saving = false.obs;
  final error = ''.obs;
  late final String entryId = existing?.id ?? const Uuid().v4();

  TransportationModel buildEntry() {
    final issue = departure.issue ?? arrival.issue;
    if (issue != null) throw FormatException(issue);
    final entry = TransportationModel(
      id: entryId,
      tripId: tripId,
      userId: existing?.userId ?? userId,
      displayName: existing?.displayName ?? displayName,
      source: existing?.source ?? TransportationSource.transportation,
      hasLegacyMirror: existing?.hasLegacyMirror ?? false,
      mode: mode.value,
      departure: departure.value,
      arrival: arrival.value,
      notes: notes.text,
    );
    if (entry.issue != null) throw FormatException(entry.issue!);
    return entry;
  }

  @override
  void onClose() {
    notes.dispose();
    departure.dispose();
    arrival.dispose();
    super.onClose();
  }
}
