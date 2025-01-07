import 'package:auth_riverpod/src/features/auth/data/firebase_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:auth_riverpod/src/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Placeholder widget showing a message and CTA to go back to the home screen.
class EmptyPlaceholderWidget extends ConsumerWidget {
  const EmptyPlaceholderWidget({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 32,
            ),
            PrimaryButton(
              onPressed: () {
                // final isLoggedIn =
                //     ref.watch(authControllerProvider).hasValue != null;
                // context.goNamed(
                //     isLoggedIn ? AppRoute.home.name : AppRoute.signIn.name);
              },
              text: 'Go Home',
            )
          ],
        ),
      ),
    );
  }
}
