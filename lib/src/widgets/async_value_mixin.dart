import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin AsyncValueMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isLoading = false;
  OverlayEntry? _overlayEntry;

  void handleAsyncValue<V>(
    AsyncValue<V> value, {
    ErrorDisplayType errorDisplayType = ErrorDisplayType.snackbar,
    bool skipLoadingOnRefresh = false,
    bool skipLoadingOnReload = true,
    void Function(Object error)? onError,
  }) {
    AsyncValueListener<V>(
      value: value,
      errorDisplayType: errorDisplayType,
      skipLoadingOnRefresh: skipLoadingOnRefresh,
      skipLoadingOnReload: skipLoadingOnReload,
      onError: onError,
      child: const SizedBox.shrink(),
    ).build(context, ref);
  }

  Future<R?> runAsync<R>(
    Future<R> Function() operation, {
    String? loadingMessage,
    ErrorDisplayType errorDisplayType = ErrorDisplayType.snackbar,
    void Function(Object error)? onError,
  }) async {
    if (_isLoading) return null;

    try {
      _isLoading = true;
      _showLoadingOverlay(loadingMessage);

      final result = await operation();
      return result;
    } catch (e, st) {
      onError?.call(e);
      switch (errorDisplayType) {
        case ErrorDisplayType.dialog:
          if (!mounted) return null;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        case ErrorDisplayType.snackbar:
          if (!mounted) return null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
      }
      return null;
    } finally {
      _hideLoadingOverlay();
      _isLoading = false;
    }
  }

  void _showLoadingOverlay(String? message) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (mounted) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _hideLoadingOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideLoadingOverlay();
    super.dispose();
  }
}
