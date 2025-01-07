import 'package:auth_riverpod/src/features/account/presentation/profile_controller.dart';
import 'package:auth_riverpod/src/features/account/presentation/profile_settings_button.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/widgets/reauthenticationdialog.dart';
import 'package:auth_riverpod/src/features/widgets/address_widget.dart';
import 'package:auth_riverpod/src/features/widgets/info_row_widget.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:auth_riverpod/src/util/url_launcher_utils.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:auth_riverpod/src/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/circular_profile_image.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return AsyncValueListener<AppUser?>(
      value: profileState,
      child: Scaffold(
        body: profileState.when(
          data: (user) {
            if (user == null) return const SizedBox();

            return CustomScrollView(
              slivers: [
                _buildAppBar(user),
                // SliverToBoxAdapter(
                //   child: Transform.translate(
                //     offset: const Offset(0, -40),
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16),
                //       child: Column(
                //         children: [
                //           _buildProfileHeader(user),
                //           const SizedBox(height: 24),
                //           _buildInfoCard(user),
                //           const SizedBox(height: 16),
                //           _buildStatusCard(user),
                //           const SizedBox(height: 24),
                //           const Divider(),
                //           _buildDangerZone(),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Update the SliverToBoxAdapter padding
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(
                        0, 0), // Adjust to match the profile image overlap
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
                          _buildDangerZone(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
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

  // Widget _buildAddressRow(String address) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.location_on,
  //           size: 20,
  //           color: Theme.of(context).primaryColor,
  //         ),
  //         const SizedBox(width: 8),
  //         const Text(
  //           'Address',
  //           style: TextStyle(
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const Spacer(),
  //         Expanded(
  //           flex: 2,
  //           child: AddressWidgetWithPreference(
  //             address: address,
  //             showIcon: false,
  //             textStyle: TextStyle(
  //               color: Theme.of(context).primaryColor,
  //               decoration: TextDecoration.underline,
  //             ),
  //             onTap: () => context.launchMap(address),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Once you delete your account, there is no going back. Please be certain.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteAccountConfirmation(),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color:
                  onTap != null ? Theme.of(context).primaryColor : Colors.grey,
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
              value,
              style: TextStyle(
                color: onTap != null ? Theme.of(context).primaryColor : null,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingInfoRow(
    IconData icon,
    String label,
    String placeholder,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            placeholder,
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showReauthenticationDialog();
    }
  }

  void _showReauthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReauthenticationDialog(
        onReauthSuccess: () => _deleteAccount(),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (mounted) {
        ref.read(routerControllerProvider.notifier).goToAuth();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
