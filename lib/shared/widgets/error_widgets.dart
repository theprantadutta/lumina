import 'package:flutter/material.dart';
import 'package:lumina/core/error/error_handler.dart';
import 'package:lumina/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

/// Error display widgets for different scenarios
class ErrorWidgets {
  /// Generic error widget with retry functionality
  static Widget errorCard({
    required ErrorInfo errorInfo,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return ErrorCard(
      errorInfo: errorInfo,
      onRetry: onRetry,
      onDismiss: onDismiss,
    );
  }

  /// Full screen error page
  static Widget fullScreenError({
    required ErrorInfo errorInfo,
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) {
    return FullScreenError(
      errorInfo: errorInfo,
      onRetry: onRetry,
      onGoHome: onGoHome,
    );
  }

  /// Inline error message
  static Widget inlineError({
    required String message,
    VoidCallback? onRetry,
  }) {
    return InlineError(
      message: message,
      onRetry: onRetry,
    );
  }

  /// Network error with illustration
  static Widget networkError({
    VoidCallback? onRetry,
  }) {
    return NetworkErrorWidget(onRetry: onRetry);
  }

  /// Empty state with optional error
  static Widget emptyState({
    required String title,
    required String message,
    String? lottieAsset,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return EmptyStateWidget(
      title: title,
      message: message,
      lottieAsset: lottieAsset,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}

/// Error card widget
class ErrorCard extends StatelessWidget {
  final ErrorInfo errorInfo;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorCard({
    super.key,
    required this.errorInfo,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorInfo.severity.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: errorInfo.severity.color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: errorInfo.severity.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    errorInfo.severity.icon,
                    color: errorInfo.severity.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        errorInfo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        errorInfo.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.textDark.withValues(alpha: 0.5),
                  ),
              ],
            ),
            if (errorInfo.retryable && onRetry != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try Again'),
                    style: TextButton.styleFrom(
                      foregroundColor: errorInfo.severity.color,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full screen error widget
class FullScreenError extends StatelessWidget {
  final ErrorInfo errorInfo;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const FullScreenError({
    super.key,
    required this.errorInfo,
    this.onRetry,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: errorInfo.severity.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorInfo.severity.icon,
                  size: 60,
                  color: errorInfo.severity.color,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                errorInfo.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorInfo.message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onGoHome != null) ...[
                    OutlinedButton(
                      onPressed: onGoHome,
                      child: const Text('Go Home'),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (errorInfo.retryable && onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorInfo.severity.color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error widget
class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // You can replace this with a Lottie animation
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please check your internet connection and try again.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textDark.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottieAsset != null) ...[
            SizedBox(
              width: 120,
              height: 120,
              child: Lottie.asset(lottieAsset!),
            ),
          ] else ...[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textDark.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(ErrorInfo errorInfo)? errorWidgetBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidgetBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  ErrorInfo? _errorInfo;

  @override
  void initState() {
    super.initState();
    
    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorInfo = ErrorHandler.handleError(
        details.exception,
        stackTrace: details.stack,
      );
      ErrorHandler.logError(errorInfo);
      
      if (mounted) {
        setState(() {
          _errorInfo = errorInfo;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorInfo != null) {
      return widget.errorWidgetBuilder?.call(_errorInfo!) ??
          ErrorWidgets.fullScreenError(
            errorInfo: _errorInfo!,
            onRetry: () {
              setState(() {
                _errorInfo = null;
              });
            },
          );
    }
    
    return widget.child;
  }
}