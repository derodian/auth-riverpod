import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingApprovalScreen extends ConsumerWidget {
  const WaitingApprovalScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).reload();
  }

  Future<void> _signOut(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    ref.read(routerControllerProvider.notifier).goToAuth();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Listen for approval status changes
    ref.listen<AsyncValue<AppUser?>>(
      authControllerProvider,
      (previous, next) {
        next.whenData((user) {
          if (user?.isAdminApproved ?? false) {
            ref.read(routerControllerProvider.notifier).goToHome();
          }
        });
      },
    );

    return AsyncValueListener<void>(
      value: authState.isLoading ? const AsyncLoading() : const AsyncData(null),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Waiting for Approval'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _signOut(ref),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 100,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Waiting for Admin Approval',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account is pending approval from an administrator. '
                'This usually takes 1-2 business days. '
                'You\'ll be notified when your account is approved.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _refresh(ref),
                icon: const Icon(Icons.refresh),
                label: const Text('Check Approval Status'),
              ),
              const SizedBox(height: 16),
              // Optional: Add contact information or support link
              TextButton.icon(
                onPressed: () {
                  // Add support contact functionality
                },
                icon: const Icon(Icons.contact_support),
                label: const Text('Contact Support'),
              ),
              const SizedBox(height: 24),
              // Optional: Add estimated wait time
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Estimated Wait Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1-2 Business Days'),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: null, // Indeterminate progress
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // Optional: Add a provider for approval configuration
// @riverpod
// class ApprovalConfig extends _$ApprovalConfig {
//   @override
//   ({Duration refreshInterval, String supportEmail}) build() {
//     return (
//       refreshInterval: const Duration(minutes: 5),
//       supportEmail: 'support@example.com',
//     );
//   }
// }

// // Optional: Add a service to handle support contact
// @riverpod
// class SupportService extends _$SupportService {
//   @override
//   void build() {}

//   Future<void> contactSupport(String userId) async {
//     // Implement support contact logic
//   }
// }
