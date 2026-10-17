/// Travel schedules display the wall clock at the venue, not at the device.
/// Keep the supplied offset separately so saving and calendar exports preserve
/// the instant. An offset is specific to the supplied date, not a timezone rule.
class TravelTime {
  static DateTime withClock(
    DateTime date,
    int hour,
    int minute,
    String? zone,
  ) =>
      zone == null
          ? DateTime(date.year, date.month, date.day, hour, minute)
          : DateTime.utc(date.year, date.month, date.day, hour, minute);

  static final _offset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$');

  static String? offset(String? value) =>
      value != null && value.contains(RegExp('[Tt ]'))
          ? _offset.firstMatch(value)?.group(0)
          : null;

  static Map<String, String> offsets(
    Map<String, dynamic> values,
    Iterable<String> fields,
  ) => {
    for (final field in fields)
      if (offset(values[field] as String?) case final String zone) field: zone,
  };

  static DateTime parse(String value) {
    // Validate the complete timestamp before extracting its wall clock.
    final parsed = DateTime.parse(value);
    final zone = offset(value);
    if (zone == null) return parsed;
    // UTC here is a wall-clock container: it avoids the phone's DST gaps
    // changing a valid time at a different destination. Use instant() for math.
    return DateTime.parse('${value.substring(0, value.length - zone.length)}Z');
  }

  static DateTime? tryParse(String? value) {
    if (value == null) return null;
    try {
      return parse(value);
    } on FormatException {
      return null;
    }
  }

  static String? serialize(DateTime? wallTime, String? zone) {
    if (wallTime == null) return null;
    final text = wallTime.toIso8601String();
    if (zone == null) return text;
    return '${text.replaceFirst(RegExp(r'Z$'), '')}$zone';
  }

  static DateTime? instant(DateTime? wallTime, String? zone) =>
      wallTime == null ? null : DateTime.parse(serialize(wallTime, zone)!);
}
