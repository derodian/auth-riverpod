// widgets/provider_reauthentication_dialog.dart
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderReauthenticationDialog extends ConsumerWidget {
  final AppAuthProvider provider;
  final Future<void> Function() onSubmit;

  const ProviderReauthenticationDialog({
    super.key,
    required this.provider,
    required this.onSubmit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required AppAuthProvider provider,
    required Future<void> Function() onSubmit,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProviderReauthenticationDialog(
        provider: provider,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
