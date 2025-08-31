import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

/// Comprehensive error handling system
class ErrorHandler {
  /// Handle various types of errors and return user-friendly messages
  static ErrorInfo handleError(dynamic error, {StackTrace? stackTrace}) {
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error);
    } else if (error is FirebaseException) {
      return _handleFirebaseError(error);
    } else if (error is SocketException) {
      return _handleNetworkError(error);
    } else if (error is FormatException) {
      return _handleFormatError(error);
    } else if (error is TimeoutException) {
      return _handleTimeoutError(error);
    } else {
      return _handleGenericError(error, stackTrace);
    }
  }

  /// Handle Firebase Auth specific errors
  static ErrorInfo _handleFirebaseAuthError(FirebaseAuthException error) {
    String title;
    String message;
    ErrorSeverity severity = ErrorSeverity.medium;

    switch (error.code) {
      case 'user-not-found':
        title = 'Account Not Found';
        message = 'No account found with this email address. Please check your email or create a new account.';
        break;
      case 'wrong-password':
        title = 'Incorrect Password';
        message = 'The password you entered is incorrect. Please try again or reset your password.';
        break;
      case 'email-already-in-use':
        title = 'Email Already Registered';
        message = 'An account with this email already exists. Please sign in or use a different email.';
        break;
      case 'weak-password':
        title = 'Weak Password';
        message = 'Please choose a stronger password with at least 6 characters.';
        break;
      case 'invalid-email':
        title = 'Invalid Email';
        message = 'Please enter a valid email address.';
        break;
      case 'user-disabled':
        title = 'Account Disabled';
        message = 'This account has been disabled. Please contact support for assistance.';
        severity = ErrorSeverity.high;
        break;
      case 'too-many-requests':
        title = 'Too Many Attempts';
        message = 'Too many failed login attempts. Please wait a moment and try again.';
        break;
      case 'network-request-failed':
        title = 'Network Error';
        message = 'Please check your internet connection and try again.';
        break;
      default:
        title = 'Authentication Error';
        message = 'An authentication error occurred. Please try again.';
        break;
    }

    return ErrorInfo(
      title: title,
      message: message,
      severity: severity,
      errorCode: error.code,
      originalError: error,
    );
  }

  /// Handle Firestore and Firebase specific errors
  static ErrorInfo _handleFirebaseError(FirebaseException error) {
    String title = 'Data Error';
    String message;
    ErrorSeverity severity = ErrorSeverity.medium;

    switch (error.code) {
      case 'permission-denied':
        message = 'You don\'t have permission to access this data.';
        severity = ErrorSeverity.high;
        break;
      case 'not-found':
        message = 'The requested data was not found.';
        break;
      case 'already-exists':
        message = 'This data already exists.';
        break;
      case 'resource-exhausted':
        title = 'Service Limit Reached';
        message = 'Service is temporarily unavailable. Please try again later.';
        severity = ErrorSeverity.high;
        break;
      case 'failed-precondition':
        message = 'Operation cannot be completed due to current conditions.';
        break;
      case 'aborted':
        message = 'Operation was aborted. Please try again.';
        break;
      case 'out-of-range':
        message = 'Invalid data provided.';
        break;
      case 'unavailable':
        title = 'Service Unavailable';
        message = 'Service is temporarily unavailable. Please try again later.';
        severity = ErrorSeverity.high;
        break;
      default:
        message = 'A data error occurred. Please try again.';
        break;
    }

    return ErrorInfo(
      title: title,
      message: message,
      severity: severity,
      errorCode: error.code,
      originalError: error,
    );
  }

  /// Handle network-related errors
  static ErrorInfo _handleNetworkError(SocketException error) {
    return ErrorInfo(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      severity: ErrorSeverity.medium,
      errorCode: 'network-error',
      originalError: error,
      actionable: true,
      retryable: true,
    );
  }

  /// Handle format and parsing errors
  static ErrorInfo _handleFormatError(FormatException error) {
    return ErrorInfo(
      title: 'Data Format Error',
      message: 'Invalid data format received. Please try again.',
      severity: ErrorSeverity.low,
      errorCode: 'format-error',
      originalError: error,
      retryable: true,
    );
  }

  /// Handle timeout errors
  static ErrorInfo _handleTimeoutError(TimeoutException error) {
    return ErrorInfo(
      title: 'Request Timeout',
      message: 'The request took too long to complete. Please check your connection and try again.',
      severity: ErrorSeverity.medium,
      errorCode: 'timeout',
      originalError: error,
      actionable: true,
      retryable: true,
    );
  }

  /// Handle generic errors
  static ErrorInfo _handleGenericError(dynamic error, StackTrace? stackTrace) {
    return ErrorInfo(
      title: 'Unexpected Error',
      message: 'Something went wrong. Please try again or contact support if the problem persists.',
      severity: ErrorSeverity.low,
      errorCode: 'generic-error',
      originalError: error,
      stackTrace: stackTrace,
      retryable: true,
    );
  }

  /// Log error for debugging
  static void logError(ErrorInfo errorInfo) {
    debugPrint('🚨 ERROR: ${errorInfo.title}');
    debugPrint('📝 Message: ${errorInfo.message}');
    debugPrint('🔍 Code: ${errorInfo.errorCode}');
    debugPrint('⚡ Severity: ${errorInfo.severity.name}');
    
    if (errorInfo.originalError != null) {
      debugPrint('🔥 Original Error: ${errorInfo.originalError}');
    }
    
    if (errorInfo.stackTrace != null) {
      debugPrint('📚 Stack Trace: ${errorInfo.stackTrace}');
    }
  }
}

/// Error information container
class ErrorInfo {
  final String title;
  final String message;
  final ErrorSeverity severity;
  final String errorCode;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final bool actionable;
  final bool retryable;

  const ErrorInfo({
    required this.title,
    required this.message,
    required this.severity,
    required this.errorCode,
    this.originalError,
    this.stackTrace,
    this.actionable = false,
    this.retryable = false,
  });
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error severity extension
extension ErrorSeverityExtension on ErrorSeverity {
  Color get color {
    switch (this) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  IconData get icon {
    switch (this) {
      case ErrorSeverity.low:
        return Icons.info_outline;
      case ErrorSeverity.medium:
        return Icons.warning_amber_outlined;
      case ErrorSeverity.high:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }
}

/// Custom exception for app-specific errors
class LuminaException implements Exception {
  final String message;
  final String code;
  final ErrorSeverity severity;
  final dynamic originalError;

  const LuminaException({
    required this.message,
    required this.code,
    this.severity = ErrorSeverity.medium,
    this.originalError,
  });

  @override
  String toString() => 'LuminaException: $message';
}

/// Timeout exception wrapper
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  const TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (timeout: ${timeout.inSeconds}s)';
}