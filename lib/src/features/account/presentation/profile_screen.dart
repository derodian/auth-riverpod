import 'dart:io' show Platform;

import 'package:auth_riverpod/src/features/account/presentation/email_reauthentication_dialog.dart';
import 'package:auth_riverpod/src/features/account/presentation/profile_controller.dart';
import 'package:auth_riverpod/src/features/account/presentation/profile_settings_button.dart';
import 'package:auth_riverpod/src/features/auth/data/reauthentication_required_exception.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/widgets/reauthenticationdialog.dart';
import 'package:auth_riverpod/src/features/widgets/info_row_widget.dart';
import 'package:auth_riverpod/src/services/snackbar_service.dart';
import 'package:auth_riverpod/src/util/url_launcher_utils.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:auth_riverpod/src/widgets/async_value_mixin.dart';
import 'package:auth_riverpod/src/widgets/async_value_widget.dart';
import 'package:auth_riverpod/src/widgets/combined_async_value_widget.dart';
import 'package:auth_riverpod/src/widgets/custom_icon_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/circular_profile_image.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AsyncValueMixin<ProfileScreen> {
  Future<void> _handleDeleteAccount() async {
    // First confirmation
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed != true || !mounted) return;

    // Get current user and their auth provider
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    try {
      // Show reauthentication dialog based on provider
      final bool reauthed;
      if (user.provider == AppAuthProvider.email) {
        reauthed = await EmailReauthenticationDialog.show(
          context,
          email: user.email,
          onSubmit: (password) => _handlePasswordSubmission(password),
        );
      } else {
        reauthed = await _showProviderReauthenticationDialog(user.provider);
      }

      if (!reauthed || !mounted) return;

      // If reauthentication successful, proceed with deletion
      await ref.read(authControllerProvider.notifier).deleteAccount();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      SnackBarService.showError(_getErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      SnackBarService.showError('Failed to delete account: $e');
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'requires-recent-login' => 'Please sign in again to delete your account',
      'user-not-found' => 'Account not found',
      'network-request-failed' => 'Network error. Please try again',
      _ => 'Error: ${e.message ?? 'Unknown error occurred'}',
    };
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to delete your account? This action:',
                ),
                const SizedBox(height: 16),
                ...[
                  'Cannot be undone',
                  'Will delete all your data',
                  'Will end all your sessions'
                ].map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(text)),
                        ],
                      ),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handlePasswordSubmission(String password) async {
    if (!mounted) return;

    try {
      await ref
          .read(authControllerProvider.notifier)
          .reauthenticateWithPassword(
            email: ref.read(authControllerProvider).value!.email,
            password: password,
          );
    } on FirebaseAuthException catch (e) {
      String errorMessage = switch (e.code) {
        'wrong-password' => 'Incorrect password. Please try again.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        'user-mismatch' => 'Authentication failed. Please try again.',
        _ => 'Authentication failed: ${e.message}',
      };
      // Use global SnackBarService
      SnackBarService.showError(errorMessage);
      rethrow;
    } catch (e) {
      // Use global SnackBarService
      SnackBarService.showError('Authentication failed: $e');
      rethrow;
    }
  }

// Update other error handling in the file to use SnackBarService
  Future<void> _handleLinkProvider(AppAuthProvider provider) async {
    try {
      await ref.read(authControllerProvider.notifier).linkProvider(provider);
      if (!mounted) return;
      SnackBarService.showSuccess(
        'Successfully linked ${_getProviderName(provider)}',
      );
    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }

  Future<void> _handleUnlinkProvider(AppAuthProvider provider) async {
    try {
      await ref.read(authControllerProvider.notifier).unlinkProvider(provider);
      if (!mounted) return;
      SnackBarService.showSuccess(
        'Successfully unlinked ${_getProviderName(provider)}',
      );
    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }

  Future<bool> _showProviderReauthenticationDialog(
      AppAuthProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Your Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please confirm your identity using ${_getProviderName(provider)} to delete your account.',
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await runAsync(
                    () => ref
                        .read(authControllerProvider.notifier)
                        .reauthenticateWithProvider(provider),
                    loadingMessage: 'Authenticating...',
                  );
                  if (!mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context, false);
                  SnackBarService.showError('Authentication failed: $e');
                }
              },
              icon: FaIcon(_getProviderIcon(provider)),
              label: Text('Continue with ${_getProviderName(provider)}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getProviderColor(provider),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    // Handle null case and mounted check
    if (confirmed != true || !mounted) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return CombinedAsyncValue(
      values: [profileState, authState],
      child: Scaffold(
        body: ScaffoldAsyncValueWidget(
          value: profileState,
          data: (user) => CustomScrollView(
            slivers: [
              _buildAppBar(user!),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildProfileHeader(user),
                        const SizedBox(height: 24),
                        _buildInfoCard(user),
                        const SizedBox(height: 16),
                        _buildStatusCard(user),
                        const SizedBox(height: 24),
                        const Divider(),
                        // Authentication providers section
                        const SizedBox(height: 24),
                        Text(
                          'Connected Accounts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...user.linkedProviders.map((provider) {
                          final authProvider =
                              AppAuthProvider.values.firstWhere(
                            (e) => e.name == provider,
                            orElse: () => AppAuthProvider.email,
                          );
                          return ListTile(
                            leading: FaIcon(
                              _getProviderIcon(authProvider),
                              size: 20,
                              color: _getProviderColor(authProvider),
                            ),
                            title: Text(_getProviderName(authProvider)),
                            trailing: user.linkedProviders.length > 1
                                ? IconButton(
                                    icon: const Icon(Icons.link_off),
                                    onPressed: () =>
                                        _handleUnlinkProvider(authProvider),
                                    tooltip: 'Unlink account',
                                  )
                                : null,
                          );
                        }),
                        // Add new provider section
                        if (_getAvailableProviders(user).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Add Account',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._getAvailableProviders(user).map((provider) {
                            return ListTile(
                              leading: FaIcon(
                                _getProviderIcon(provider),
                                size: 20,
                                color: _getProviderColor(provider),
                              ),
                              title: Text('Add ${_getProviderName(provider)}'),
                              onTap: () => _handleLinkProvider(provider),
                            );
                          }),
                        ],

                        const SizedBox(height: 24),
                        const Divider(),
                        _buildDangerZone(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AppUser user) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: Stack(
        clipBehavior: Clip.none,
        children: [
          FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (user.profileBackgroundUrl != null)
                  CachedNetworkImage(
                    imageUrl: user.profileBackgroundUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        _buildGradientBackground(context),
                  )
                else
                  _buildGradientBackground(context),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black45, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Position the profile image at the bottom center of the app bar
          Positioned(
            bottom: -50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProfileImage(
                imageUrl: user.profileImageUrl,
                radius: 75,
                borderWidth: 3,
                borderColor: Colors.white,
                shimmerBaseColor: Colors.grey[300],
                shimmerHighlightColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      leading: CustomIconButton(
        icon: Icons.arrow_back,
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        const ProfileSettingsButton(),
        CustomIconButton(
          icon: Icons.edit,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(user: user),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGradientBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => context.launchEmail(user.email),
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            InfoRow(
              icon: Icons.phone,
              label: 'Phone',
              value: user.phoneNumber,
              onTap: () => context.launchPhone(user.phoneNumber!),
            ),
            InfoRow(
              icon: Icons.location_on,
              label: 'Address',
              value: user.address,
              type: InfoType.address,
              onTap: () => context.launchMap(user.address!),
              showDistance: true,
            ),
            InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
              onTap: () => context.launchEmail(user.email),
            ),
            InfoRow(
              icon: Icons.calendar_today,
              label: 'Member Since',
              type: InfoType.date,
              value: user.createdAt.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildStatusRow(
              'Email Verified',
              user.isEmailVerified,
            ),
            _buildStatusRow(
              'Admin Approved',
              user.isAdminApproved,
            ),
            if (user.isAdmin)
              _buildStatusRow(
                'Admin Access',
                true,
              ),
            InfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: user.lastUpdatedAt.toString(),
              type: InfoType.date,
              showElapsedTime: true,
            ),
            InfoRow(
              icon: Icons.access_time,
              label: 'Last Login',
              value: DateTime.now()
                  .subtract(const Duration(hours: 3, minutes: 15))
                  .toString(),
              type: InfoType.date,
              showElapsedTime: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Once you delete your account, there is no going back. '
              'This will permanently delete:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            ...['Your profile', 'Your data', 'Your settings']
                .map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.remove_circle,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            text,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _handleDeleteAccount,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.delete_forever),
                label: Text(isLoading ? 'Deleting...' : 'Delete Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              color: value ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  List<AppAuthProvider> _getAvailableProviders(AppUser user) {
    final allProviders = [
      AppAuthProvider.google,
      if (Platform.isIOS || Platform.isMacOS || kIsWeb) AppAuthProvider.apple,
      AppAuthProvider.facebook,
      AppAuthProvider.github,
    ];
    return allProviders
        .where((provider) => !user.linkedProviders.contains(provider.name))
        .toList();
  }

  IconData _getProviderIcon(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        return FontAwesomeIcons.google;
      case AppAuthProvider.apple:
        return FontAwesomeIcons.apple;
      case AppAuthProvider.facebook:
        return FontAwesomeIcons.facebookF;
      case AppAuthProvider.github:
        return FontAwesomeIcons.github;
      default:
        return FontAwesomeIcons.envelope;
    }
  }

  String _getProviderName(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        return 'Google';
      case AppAuthProvider.apple:
        return 'Apple';
      case AppAuthProvider.facebook:
        return 'Facebook';
      case AppAuthProvider.github:
        return 'GitHub';
      default:
        return 'Email';
    }
  }

  Color _getProviderColor(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        return const Color(0xFFDB4437);
      case AppAuthProvider.apple:
        return const Color(0xFF000000);
      case AppAuthProvider.facebook:
        return const Color(0xFF1877F2);
      case AppAuthProvider.github:
        return const Color(0xFF333333);
      default:
        return Colors.blue;
    }
  }
}
