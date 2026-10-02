import 'dart:async';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Performance monitoring utility for tracking app performance
/// Provides timing measurements and performance analytics
class PerformanceMonitor {
  static final Map<String, DateTime> _timers = <String, DateTime>{};
  static final Map<String, List<int>> _measurements = <String, List<int>>{};

  /// Start a performance timer with a given name
  static void startTimer(String name) {
    _timers[name] = DateTime.now();
    AppLogger.debug(
      'Performance timer started: $name',
      tag: 'PerformanceMonitor',
    );
  }

  /// End a performance timer and log the duration
  static int? endTimer(String name, {bool logResult = true}) {
    final DateTime? startTime = _timers[name];
    if (startTime == null) {
      AppLogger.warning(
        'Timer "$name" was not started',
        tag: 'PerformanceMonitor',
      );
      return null;
    }

    final DateTime endTime = DateTime.now();
    final int durationMs = endTime.difference(startTime).inMilliseconds;

    // Store measurement for analytics
    _measurements.putIfAbsent(name, () => <int>[]).add(durationMs);

    // Remove the timer
    _timers.remove(name);

    if (logResult) {
      AppLogger.info(
        'Performance: $name took ${durationMs}ms',
        tag: 'PerformanceMonitor',
      );
    }

    // Warn about slow operations
    if (durationMs > 1000) {
      AppLogger.warning(
        'Slow operation detected: $name took ${durationMs}ms',
        tag: 'PerformanceMonitor',
      );
    }

    return durationMs;
  }

  /// Measure the execution time of a synchronous operation
  static T measureSync<T>(String name, T Function() operation) {
    startTimer(name);
    try {
      final T result = operation();
      endTimer(name);
      return result;
    } catch (error) {
      endTimer(name);
      rethrow;
    }
  }

  /// Measure the execution time of an asynchronous operation
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    startTimer(name);
    try {
      final T result = await operation();
      endTimer(name);
      return result;
    } catch (error) {
      endTimer(name);
      rethrow;
    }
  }

  /// Get performance statistics for a given timer name
  static PerformanceStats? getStats(String name) {
    final List<int>? measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) {
      return null;
    }

    final List<int> sortedMeasurements = List<int>.from(measurements)..sort();
    final int count = measurements.length;
    final int sum = measurements.reduce((int a, int b) => a + b);
    final double average = sum / count;
    final int min = sortedMeasurements.first;
    final int max = sortedMeasurements.last;
    final int median = sortedMeasurements[count ~/ 2];

    return PerformanceStats(
      name: name,
      count: count,
      average: average,
      min: min,
      max: max,
      median: median,
      total: sum,
    );
  }

  /// Get all performance statistics
  static Map<String, PerformanceStats> getAllStats() {
    final Map<String, PerformanceStats> allStats = <String, PerformanceStats>{};

    for (final String name in _measurements.keys) {
      final PerformanceStats? stats = getStats(name);
      if (stats != null) {
        allStats[name] = stats;
      }
    }

    return allStats;
  }

  /// Log performance summary
  static void logSummary() {
    final Map<String, PerformanceStats> allStats = getAllStats();

    if (allStats.isEmpty) {
      AppLogger.info(
        'No performance measurements recorded',
        tag: 'PerformanceMonitor',
      );
      return;
    }

    AppLogger.info('Performance Summary:', tag: 'PerformanceMonitor');
    for (final PerformanceStats stats in allStats.values) {
      AppLogger.info(
        '${stats.name}: avg=${stats.average.toStringAsFixed(1)}ms, '
        'min=${stats.min}ms, max=${stats.max}ms, count=${stats.count}',
        tag: 'PerformanceMonitor',
      );
    }
  }

  /// Clear all measurements
  static void clearMeasurements() {
    _measurements.clear();
    _timers.clear();
    AppLogger.debug(
      'Performance measurements cleared',
      tag: 'PerformanceMonitor',
    );
  }

  /// Monitor memory usage (basic implementation)
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      // Note: Detailed memory monitoring would require platform-specific implementation
      AppLogger.debug('Memory check at: $context', tag: 'PerformanceMonitor');
    }
  }

  /// Monitor frame rendering performance
  static void startFrameMonitoring() {
    if (kDebugMode) {
      // This would integrate with Flutter's performance overlay
      AppLogger.debug('Frame monitoring started', tag: 'PerformanceMonitor');
    }
  }

  /// Stop frame monitoring
  static void stopFrameMonitoring() {
    if (kDebugMode) {
      AppLogger.debug('Frame monitoring stopped', tag: 'PerformanceMonitor');
    }
  }
}

/// Performance statistics data class
class PerformanceStats {
  const PerformanceStats({
    required this.name,
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.median,
    required this.total,
  });

  final String name;
  final int count;
  final double average;
  final int min;
  final int max;
  final int median;
  final int total;

  @override
  String toString() {
    return 'PerformanceStats(name: $name, count: $count, avg: ${average.toStringAsFixed(1)}ms, '
        'min: ${min}ms, max: ${max}ms, median: ${median}ms)';
  }
}
