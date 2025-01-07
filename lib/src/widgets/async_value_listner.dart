import 'package:auth_riverpod/src/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/snackbar_service.dart';

enum ErrorDisplayType {
  dialog,
  snackbar,
}

class AsyncValueListener<T> extends ConsumerWidget {
  const AsyncValueListener({
    super.key,
    required this.value,
    required this.child,
    this.errorDisplayType = ErrorDisplayType.snackbar,
    this.skipLoadingOnRefresh = false,
    this.skipLoadingOnReload = true,
    this.onError,
  });

  final AsyncValue<T> value;
  final Widget child;
  final ErrorDisplayType errorDisplayType;
  final bool skipLoadingOnRefresh;
  final bool skipLoadingOnReload;
  final void Function(Object error)? onError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLoading = switch (value) {
      AsyncData(:final isRefreshing, :final isReloading) =>
        isRefreshing && !skipLoadingOnRefresh ||
            isReloading && !skipLoadingOnReload,
      AsyncLoading() => true,
      _ => false,
    };

    // Handle errors
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
    }

    return LoadingOverlay(
      isLoading: showLoading,
      child: child,
    );
  }
}
