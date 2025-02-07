// lib/features/auth/widgets/email_password_form.dart
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/enum/auth_form_type.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/utils/provider_utils.dart';
import 'package:auth_riverpod/src/features/auth/widgets/password_requirement.dart';
import 'package:auth_riverpod/src/features/widgets/custom_text_form_field.dart';
import 'package:auth_riverpod/src/util/formatters.dart';
import 'package:auth_riverpod/src/util/validators.dart';
import 'package:auth_riverpod/src/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailPasswordForm extends ConsumerStatefulWidget {
  const EmailPasswordForm({
    super.key,
    required this.formType,
    required this.onSubmit,
    required this.onFormTypeChange,
    this.enabled = true,
  });

  final AuthFormType formType;
  final bool enabled;
  final void Function(String email, String password,
      [String? name, String? phone]) onSubmit;
  final void Function(AuthFormType) onFormTypeChange;

  @override
  ConsumerState<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends ConsumerState<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  double _passwordStrength = 0.0;

  bool get _isSignUp => widget.formType.isSignUp;
  bool get _isSignIn => widget.formType.isSignIn;
  bool get _isForgotPassword => widget.formType.isForgotPassword;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _validateEmail(_emailController.text);
        // Only proceed with submission if email validation passes
        widget.onSubmit(
          _emailController.text,
          _passwordController.text,
          _isSignUp ? _nameController.text : null,
          _isSignUp ? _phoneController.text : null,
        );
      } catch (e) {
        debugPrint('Submit error: $e');
        // Don't proceed with submission if validation fails
      }
    }
  }

  Future<void> _validateEmail(String email) async {
    if (_isSignUp) {
      debugPrint('Validating email: $email');
      final authController = ref.read(authControllerProvider.notifier);
      try {
        final providers = await authController.checkEmailProviders(email);
        debugPrint('Found providers: $providers');

        if (providers.isNotEmpty && mounted) {
          // Add logging before showing dialog
          debugPrint('Showing provider selection dialog');
          return await showDialog(
            barrierDismissible: false, // Prevent dismissing by tapping outside
            context: context,
            builder: (context) => ProviderSelectionDialog(
              providers: providers,
              onProviderSelected: _handleExistingProvider,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error validating email: $e');
        rethrow;
      }
    }
  }

  void _handleExistingProvider(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        ref.read(authControllerProvider.notifier).signInWithGoogle();
        break;
      case AppAuthProvider.apple:
        ref.read(authControllerProvider.notifier).signInWithApple();
        break;
      default:
        widget.onFormTypeChange(AuthFormType.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSignUp) ...[
            CustomTextFormField(
              label: 'Full Name',
              prefix: Icon(Icons.person),
              controller: _nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              inputFormatters: FormattedFields.nameFormatters,
              validator: Validators.validateFullName,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Phone Number',
              prefix: Icon(Icons.phone),
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textCapitalization: TextCapitalization.none,
              inputFormatters: FormattedFields.phoneFormatters,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),
          ],
          CustomTextFormField(
            label: 'Email',
            prefix: Icon(Icons.email),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            validator: Validators.validateEmail,
          ),
          if (!_isForgotPassword) ...[
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Password',
              prefix: Icon(Icons.key),
              controller: _passwordController,
              isPassword: true,
              validator: _isSignIn ? null : Validators.validatePassword,
            ),
          ],
          if (_isSignUp) ...[
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Confirm Password',
              prefix: Icon(Icons.key),
              controller: _confirmPasswordController,
              isPassword: true,
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            const SizedBox(height: 16),
            PasswordStrengthIndicator(strength: _passwordStrength),
            const SizedBox(height: 8),
            const PasswordRequirement(
              isValid: true,
              text: 'At least 8 characters',
            ),
            const PasswordRequirement(
              isValid: true,
              text: 'Contains uppercase letter',
            ),
            const PasswordRequirement(
              isValid: true,
              text: 'Contains number',
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
              onPressed: _submit,
              text: _isSignUp
                  ? 'Sign Up'
                  : _isSignIn
                      ? 'Sign In'
                      : 'Reset Password')
        ],
      ),
    );
  }
}

// Create a separate dialog widget for better organization
class ProviderSelectionDialog extends StatelessWidget {
  final List<AppAuthProvider> providers;
  final Function(AppAuthProvider) onProviderSelected;

  const ProviderSelectionDialog({
    super.key,
    required this.providers,
    required this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Email Already Registered'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('This email is already registered. Please sign in using:'),
          const SizedBox(height: 16),
          ...providers.map((provider) => ListTile(
                leading: FaIcon(
                  ProviderUtils.getProviderIcon(provider),
                  color: ProviderUtils.getProviderColor(provider),
                ),
                title: Text(ProviderUtils.getProviderName(provider)),
                onTap: () {
                  Navigator.of(context).pop();
                  onProviderSelected(provider);
                },
              )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
