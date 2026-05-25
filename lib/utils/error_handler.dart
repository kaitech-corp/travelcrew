import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'custom_snackbar.dart';
import 'logger.dart';

/// Global error handling utility for consistent error management
/// Provides centralized error handling, logging, and user feedback
class ErrorHandler {
  /// Handle and log errors with appropriate user feedback
  static void handleError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    String? userMessage,
    bool showToUser = false,
  }) {
    // Log the error with context
    final String errorContext = context ?? 'Unknown';
    AppLogger.error(
      'Error in $errorContext: $error',
      tag: 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );

    // In debug mode, also print to console for immediate visibility
    if (kDebugMode) {
      debugPrint('🔴 ERROR [$errorContext]: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: errorContext,
        fatal: false,
      );
    }

    if (showToUser && userMessage != null) {
      _showErrorToUser(userMessage);
    }
  }

  static void _showErrorToUser(String message) {
    showCustomSnackBar(
      contentType: ContentType.failure,
      content: message,
      title: 'Error',
    );
  }

  /// Handle Firebase-specific errors with better context
  static void handleFirebaseError(
    Object error, {
    StackTrace? stackTrace,
    String? operation,
  }) {
    final String context =
        operation != null ? 'Firebase $operation' : 'Firebase';

    // Provide more specific error messages for common Firebase errors
    final String userMessage = _getFirebaseErrorMessage(error);
    final bool isFirestoreError = _isFirestoreError(error);

    handleError(
      error,
      stackTrace: stackTrace,
      context: context,
      userMessage: userMessage,
      showToUser: !isFirestoreError,
    );
  }

  static bool _isFirestoreError(Object error) {
    return error is FirebaseException && error.plugin == 'cloud_firestore';
  }

  /// Handle network-related errors
  static void handleNetworkError(
    Object error, {
    StackTrace? stackTrace,
    String? endpoint,
  }) {
    final String context =
        endpoint != null ? 'Network request to $endpoint' : 'Network request';

    handleError(
      error,
      stackTrace: stackTrace,
      context: context,
      userMessage:
          'Network connection error. Please check your internet connection.',
      showToUser: true,
    );
  }

  /// Get user-friendly error message for Firebase errors
  static String _getFirebaseErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided for that user.';
        case 'email-already-in-use':
          return 'The email address is already in use by another account.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'operation-not-allowed':
          return 'Signing in with Email and Password is not enabled.';
        default:
          return error.message ?? 'Authentication error occurred.';
      }
    }

    final String errorString = error.toString().toLowerCase();

    if (errorString.contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (errorString.contains('permission')) {
      return 'Permission denied. Please check your account permissions.';
    } else if (errorString.contains('not-found')) {
      return 'The requested data was not found.';
    } else if (errorString.contains('already-exists')) {
      return 'This item already exists.';
    } else if (errorString.contains('invalid-argument')) {
      return 'Invalid data provided. Please check your input.';
    } else if (errorString.contains('unauthenticated')) {
      return 'Please sign in to continue.';
    } else if (errorString.contains('quota-exceeded')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Wrap async operations with error handling
  static Future<T?> wrapAsync<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace, context: context);
      return fallbackValue;
    }
  }

  /// Wrap sync operations with error handling
  static T? wrapSync<T>(
    T Function() operation, {
    String? context,
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace, context: context);
      return fallbackValue;
    }
  }
}
