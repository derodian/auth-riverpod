import 'dart:io' show Platform;
import 'package:auth_riverpod/src/features/auth/data/app_user_storage_service.dart';
import 'package:auth_riverpod/src/features/auth/data/apple_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/data/firebase_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/data/google_auth_service.dart';
import 'package:auth_riverpod/src/features/auth/widgets/merge_account_dialog.dart';
import 'package:auth_riverpod/src/features/auth/widgets/social_auth_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/enum/auth_form_type.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/presentation/email_password_form.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthFormType _formType = AuthFormType.signIn;
  bool _isLoading = false;

  void _toggleFormType() {
    setState(() {
      if (_formType.isSignIn) {
        _formType = AuthFormType.signUp;
      } else {
        _formType = AuthFormType.signIn;
      }
    });
  }

  void _showForgotPassword() {
    setState(() {
      _formType = AuthFormType.forgotPassword;
    });
  }

  // Helper method to determine if we should show Apple Sign In
  bool get _showAppleSignIn {
    if (kIsWeb) return true; // Show on web
    if (Platform.isIOS || Platform.isMacOS)
      return true; // Show on Apple platforms
    return false; // Don't show on other platforms
  }

  // Helper method to get available social providers
  List<AppAuthProvider> get _socialProviders {
    final providers = <AppAuthProvider>[AppAuthProvider.google];

    if (_showAppleSignIn) {
      providers.add(AppAuthProvider.apple);
    }

    providers.addAll([
      AppAuthProvider.facebook,
      AppAuthProvider.github,
    ]);

    return providers;
  }

  Future<void> _handleSocialSignIn(AppAuthProvider provider) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final credential = await switch (provider) {
        AppAuthProvider.google =>
          ref.read(googleAuthServiceProvider).getCredential(),
        AppAuthProvider.apple =>
          ref.read(appleAuthServiceProvider).getCredential(),
        _ => throw UnsupportedError('Provider not supported'),
      };

      final userInfo = await ref
          .read(authServiceProvider)
          .getUserInfoFromCredential(credential);

      final exists = await ref
          .read(appUserStorageServiceProvider.notifier)
          .checkEmailExists(userInfo.email);

      if (exists && mounted) {
        final shouldMerge = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => MergeAccountDialog(
                email: userInfo.email,
                provider: provider,
                onConfirm: () => Navigator.of(context).pop(true),
                onCancel: () => Navigator.of(context).pop(false),
              ),
            ) ??
            false;

        if (!shouldMerge) {
          setState(() => _isLoading = false);
          return;
        }
      }

      await ref
          .read(authControllerProvider.notifier)
          .signInWithSocialProvider(provider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Future<void> _handleSocialSignIn(AppAuthProvider provider) async {
  //   try {
  //     switch (provider) {
  //       case AppAuthProvider.google:
  //         await ref.read(authControllerProvider.notifier).signInWithGoogle();
  //         break;
  //       case AppAuthProvider.apple:
  //         await ref.read(authControllerProvider.notifier).signInWithApple();
  //         break;
  //       // case AppAuthProvider.facebook:
  //       //   await ref.read(authControllerProvider.notifier).signInWithFacebook();
  //       //   break;
  //       // case AppAuthProvider.github:
  //       //   await ref.read(authControllerProvider.notifier).signInWithGithub();
  //       //   break;
  //       default:
  //         break;
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString())),
  //     );
  //   }
  // }

  Future<void> _onSubmit(
    String email,
    String password, [
    String? name,
    String? phone,
  ]) async {
    try {
      if (_formType.isSignIn) {
        await ref.read(authControllerProvider.notifier).signInEmail(
              email,
              password,
            );
      } else if (_formType.isSignUp) {
        await ref.read(authControllerProvider.notifier).signUp(
              email: email,
              password: password,
              name: name!,
              phoneNumber: phone!,
            );
      } else {
        await ref.read(authControllerProvider.notifier).resetPassword(email);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Password Reset Email Sent'),
              content: const Text(
                'Check your email for password reset instructions.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _formType = AuthFormType.signIn;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Submit Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600; // Adjust breakpoint as needed

    final authState = ref.watch(authControllerProvider);

    return AsyncValueListener<AppUser?>(
      value: authState,
      errorDisplayType: ErrorDisplayType.snackbar,
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      onError: (error) {
        debugPrint('Auth Error: $error');
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo section
                    _buildLogoSection(theme),

                    // Title section
                    _buildTitleSection(theme),

                    // Social auth section
                    if (!_formType.isForgotPassword) ...[
                      _buildSocialAuthSection(
                        isSmallScreen: isSmallScreen,
                        isLoading: authState.isLoading,
                      ),
                      const _OrDivider(),
                    ],

                    // Email form section
                    _buildEmailFormSection(authState.isLoading),

                    // Action buttons section
                    _buildActionButtons(
                      theme: theme,
                      isLoading: authState.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer,
          ),
          child: Icon(
            Icons.lock_outline,
            size: 48,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      children: [
        Text(
          _formType.isSignIn
              ? 'Welcome Back!'
              : _formType.isSignUp
                  ? 'Create Account'
                  : 'Reset Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _getSubtitle() {
    if (_formType.isSignIn) {
      return 'Sign in to continue to your account';
    } else if (_formType.isSignUp) {
      return 'Create an account to get started';
    } else {
      return 'Enter your email to reset your password';
    }
  }

  Widget _buildSocialAuthSection({
    required bool isSmallScreen,
    required bool isLoading,
  }) {
    return Column(
      children: [
        if (isSmallScreen)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _socialProviders.map((provider) {
              return SocialAuthButton(
                provider: provider,
                onPressed:
                    isLoading ? null : () => _handleSocialSignIn(provider),
                size: SocialButtonSize.small,
              );
            }).toList(),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _socialProviders.map((provider) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SocialAuthButton(
                  provider: provider,
                  onPressed:
                      isLoading ? null : () => _handleSocialSignIn(provider),
                  outlined: true,
                  size: SocialButtonSize.large,
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _handleFormTypeChange(AuthFormType newType) {
    setState(() {
      _formType = newType;
    });
  }

  Widget _buildEmailFormSection(bool isLoading) {
    return Column(
      children: [
        EmailPasswordForm(
          formType: _formType,
          onSubmit: _onSubmit,
          onFormTypeChange: _handleFormTypeChange,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons({
    required ThemeData theme,
    required bool isLoading,
  }) {
    return Column(
      children: [
        if (!_formType.isForgotPassword)
          TextButton(
            onPressed: isLoading ? null : _toggleFormType,
            child: Text(
              _formType.isSignIn
                  ? 'Need an account? Sign up'
                  : 'Have an account? Sign in',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        if (_formType.isSignIn)
          TextButton(
            onPressed: isLoading ? null : _showForgotPassword,
            child: Text(
              'Forgot password?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        if (_formType.isForgotPassword)
          TextButton(
            onPressed: isLoading ? null : _toggleFormType,
            child: Text(
              'Back to Sign In',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'or continue with email',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }
}
