import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/widgets/social_auth_button.dart';
import 'package:auth_riverpod/src/features/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class ReauthenticationDialog extends StatefulWidget {
  final List<String> providers;
  final Function(AppAuthProvider) onProviderSelected;
  final VoidCallback? onCancel;

  const ReauthenticationDialog({
    super.key,
    required this.providers,
    required this.onProviderSelected,
    this.onCancel,
  });

  @override
  State<ReauthenticationDialog> createState() => _ReauthenticationDialogState();
}

class _ReauthenticationDialogState extends State<ReauthenticationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleProviderSelection(AppAuthProvider provider) {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // For email provider, validate form first
    if (provider == AppAuthProvider.email) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        setState(() => _isLoading = false);
        return;
      }
    }

    // Close dialog and notify parent
    Navigator.of(context).pop();
    widget.onProviderSelected(provider);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reauthentication Required'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please reauthenticate to continue with this action.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Show email/password form if email provider is available
            if (widget.providers.contains(AppAuthProvider.email.name)) ...[
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        return null;
                      },
                      isEnabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      label: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                      isEnabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () =>
                              _handleProviderSelection(AppAuthProvider.email),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In with Email'),
                    ),
                    if (widget.providers.length > 1) ...[
                      const SizedBox(height: 16),
                      const Text('Or continue with:'),
                    ],
                  ],
                ),
              ),
            ],
            // Show social provider buttons
            ...widget.providers
                .where((p) => p != AppAuthProvider.email.name)
                .map((provider) {
              final authProvider = AppAuthProvider.values.firstWhere(
                (e) => e.name == provider,
                orElse: () => AppAuthProvider.email,
              );
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SocialAuthButton(
                  provider: authProvider,
                  onPressed: _isLoading
                      ? null
                      : () => _handleProviderSelection(authProvider),
                  isLoading: _isLoading,
                ),
              );
            }),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onCancel?.call();
                },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
