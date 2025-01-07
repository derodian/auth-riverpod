import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        await ref.read(authControllerProvider.notifier).signOut();
        if (context.mounted) {
          ref.read(routerControllerProvider.notifier).goToAuth();
        }
      },
      icon: const Icon(Icons.logout),
    );
  }
}
