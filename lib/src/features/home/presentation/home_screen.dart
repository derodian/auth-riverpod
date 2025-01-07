import 'package:auth_riverpod/src/features/account/presentation/profile_controller.dart';
import 'package:auth_riverpod/src/features/account/presentation/profile_screen.dart';
import 'package:auth_riverpod/src/features/account/widgets/circular_profile_image.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).signOut();
            if (context.mounted) {
              ref.read(routerControllerProvider.notifier).goToAuth();
            }
          },
          icon: Icon(Icons.logout_rounded),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircularProfileImage(
              imageUrl: user?.profileImageUrl,
              radius: 18,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Rest of your home screen implementation
    );
  }
}
