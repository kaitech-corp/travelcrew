import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for filtering messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Centralized logging utility with different log levels
/// Provides structured logging for better debugging and monitoring
class AppLogger {
  static const String _tag = 'TravelCrew';
  
  /// Current minimum log level (can be configured)
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  
  /// Set the minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }
  
  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_shouldLog(LogLevel.debug)) {
      _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log informational messages
  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_shouldLog(LogLevel.info)) {
      _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_shouldLog(LogLevel.warning)) {
      _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_shouldLog(LogLevel.error)) {
      _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
    }
  }
  
  /// Check if a log level should be logged
  static bool _shouldLog(LogLevel level) {
    return level.index >= _minLevel.index;
  }
  
  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final String logTag = tag ?? _tag;
    final String levelStr = level.name.toUpperCase();
    final String timestamp = DateTime.now().toIso8601String();
    
    String logMessage = '[$timestamp] [$levelStr] [$logTag] $message';
    
    if (error != null) {
      logMessage += '\nError: $error';
    }
    
    if (stackTrace != null) {
      logMessage += '\nStackTrace: $stackTrace';
    }
    
    // Use developer.log for better integration with Flutter DevTools
    developer.log(
      logMessage,
      name: logTag,
      level: _getLevelValue(level),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Convert LogLevel to int value for developer.log
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
