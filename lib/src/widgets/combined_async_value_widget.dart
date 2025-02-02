// combined_async_value.dart
import 'package:auth_riverpod/src/services/snackbar_service.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:auth_riverpod/src/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CombinedAsyncValue extends ConsumerWidget {
  final List<AsyncValue> values;
  final Widget child;
  final ErrorDisplayType errorDisplayType;
  final bool skipLoadingOnRefresh;
  final bool skipLoadingOnReload;
  final void Function(Object error)? onError;

  const CombinedAsyncValue({
    super.key,
    required this.values,
    required this.child,
    this.errorDisplayType = ErrorDisplayType.snackbar,
    this.skipLoadingOnRefresh = false,
    this.skipLoadingOnReload = true,
    this.onError,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if any value is loading
    final showLoading = values.any((value) {
      return switch (value) {
        AsyncData(:final isRefreshing, :final isReloading) =>
          isRefreshing && !skipLoadingOnRefresh ||
              isReloading && !skipLoadingOnReload,
        AsyncLoading() => true,
        _ => false,
      };
    });

    // Check for errors
    for (final value in values) {
      if (value.hasError && !value.isLoading) {
        final error = value.error.toString();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onError?.call(value.error!);

          switch (errorDisplayType) {
            case ErrorDisplayType.dialog:
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(error),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            case ErrorDisplayType.snackbar:
              SnackBarService.showError(error);
          }
        });
        break;
      }
    }

    return LoadingOverlay(
      isLoading: showLoading,
      child: child,
    );
  }
}
