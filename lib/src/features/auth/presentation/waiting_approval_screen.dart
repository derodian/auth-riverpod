import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/presentation/waiting_approval_screen_controller.dart';
import 'package:auth_riverpod/src/features/auth/widgets/support_dialog.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:auth_riverpod/src/util/url_launcher_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingApprovalScreen extends ConsumerStatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  ConsumerState<WaitingApprovalScreen> createState() =>
      _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends ConsumerState<WaitingApprovalScreen> {
  @override
  void initState() {
    super.initState();
    Future(() => ref
        .read(waitingApprovalControllerProvider.notifier)
        .startPeriodicRefresh());
  }

  void _showSupportDialog() {
    final controller = ref.read(waitingApprovalControllerProvider.notifier);
    showDialog(
      context: context,
      builder: (_) => SupportDialog(
        adminEmail: controller.getAdminEmail(),
        supportPhone: controller.getSupportPhone(),
        emailBody: controller.getEmailBody(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final approvalState = ref.watch(waitingApprovalControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isChecking = ref.watch(waitingApprovalControllerProvider);

    // Listen for approval
    ref.listen<AsyncValue<AppUser?>>(
      authControllerProvider,
      (_, next) {
        next.whenData((user) {
          if (user?.isAdminApproved ?? false) {
            ref.read(routerControllerProvider.notifier).goToHome();
          }
        });
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          _buildContent(),
          Positioned(
            top: 16 + MediaQuery.of(context).padding.top,
            right: 16,
            child: IconButton.filled(
              onPressed: () => ref
                  .read(waitingApprovalControllerProvider.notifier)
                  .signOut(),
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
            ),
          ),
        ],
      ),
    );
  }

  // Move dialog to screen
  void showSupportDialog(
      BuildContext context, WaitingApprovalController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Send Email'),
              subtitle: Text(controller.getAdminEmail()),
              onTap: () {
                Navigator.pop(context);
                context.launchEmail(
                  controller.getAdminEmail(),
                  subject: 'Account Approval Request',
                  body: controller.getEmailBody(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Contact Support'),
              subtitle: Text(controller.getSupportPhone()),
              onTap: () {
                Navigator.pop(context);
                context.launchPhone(controller.getSupportPhone());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(waitingApprovalControllerProvider.notifier)
              .checkApprovalStatus(),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 64,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Waiting for Admin Approval',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your account is pending approval from an administrator. '
                'This usually takes 1-2 business days.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => ref
                    .read(waitingApprovalControllerProvider.notifier)
                    .checkApprovalStatus(),
                icon: const Icon(Icons.refresh),
                label: const Text('Check Approval Status'),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Estimated Wait Time',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('1-2 Business Days'),
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                // onPressed: () => showDialog(
                //   context: context,
                //   builder: (_) => const SupportDialog(),
                // ),
                onPressed: _showSupportDialog,
                icon: const Icon(Icons.contact_support),
                label: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref
                  .read(waitingApprovalControllerProvider.notifier)
                  .checkApprovalStatus(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
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
