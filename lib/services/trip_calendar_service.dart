import 'package:flutter/services.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/trip_model.dart';

class TripCalendarService {
  static const channel = MethodChannel('travelcrew/calendar');

  static Map<String, dynamic> eventFor(TripModel trip) {
    final first = trip.effectiveStartDate;
    final start = DateTime.utc(first.year, first.month, first.day);
    final last = trip.tripEndDate ?? DateTime.tryParse(trip.endDate) ?? first;
    final end = DateTime.utc(last.year, last.month, last.day);
    if (end.isBefore(start)) {
      throw const FormatException('Trip end precedes start');
    }
    String date(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return {
      'title':
          trip.title?.trim().isNotEmpty == true
              ? trip.title!.trim()
              : trip.destination,
      'location': [
        trip.destination,
        trip.country,
      ].where((s) => s.trim().isNotEmpty).join(', '),
      'notes': 'Trip planned with Travel Crew',
      'startDate': date(start),
      // Calendar all-day events have an exclusive end date.
      'endDate': date(end.add(const Duration(days: 1))),
    };
  }

  static String? activityIssue(ActivityModel activity) {
    final start = activity.startInstant;
    if (start == null) return 'Set a start date and time to add this activity.';
    if (activity.endInstant != null && !activity.endInstant!.isAfter(start)) {
      return 'The end time must be after the start time.';
    }
    return null;
  }

  static Map<String, dynamic> eventForActivity(ActivityModel activity) {
    final issue = activityIssue(activity);
    if (issue != null) throw FormatException(issue);
    final start = activity.startInstant!;
    final end = activity.endInstant ?? start.add(const Duration(hours: 1));
    return {
      'title':
          activity.title.trim().isEmpty
              ? 'Travel Crew activity'
              : activity.title.trim(),
      'location': activity.location?.trim() ?? '',
      'notes': [
        activity.description.trim(),
        'Activity planned with Travel Crew',
      ].where((text) => text.isNotEmpty).join('\n\n'),
      'startMilliseconds': start.millisecondsSinceEpoch,
      'endMilliseconds': end.millisecondsSinceEpoch,
    };
  }

  static Future<void> addActivity(ActivityModel activity) =>
      channel.invokeMethod<void>('addActivity', eventForActivity(activity));

  static Future<void> addTrip(TripModel trip) =>
      channel.invokeMethod<void>('addTrip', eventFor(trip));
}
