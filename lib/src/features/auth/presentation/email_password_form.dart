// lib/features/auth/widgets/email_password_form.dart
import 'package:auth_riverpod/src/features/auth/enum/auth_form_type.dart';
import 'package:auth_riverpod/src/features/auth/widgets/password_requirement.dart';
import 'package:auth_riverpod/src/features/widgets/custom_text_form_field.dart';
import 'package:auth_riverpod/src/util/formatters.dart';
import 'package:auth_riverpod/src/util/validators.dart';
import 'package:auth_riverpod/src/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailPasswordForm extends ConsumerStatefulWidget {
  const EmailPasswordForm({
    super.key,
    required this.formType,
    required this.onSubmit,
    this.enabled = true,
  });

  final AuthFormType formType;
  final bool enabled;
  final void Function(String email, String password,
      [String? name, String? phone]) onSubmit;

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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

  void _updatePasswordStrength(String password) {
    if (!_isSignUp) return;

    double strength = 0;
    if (password.length >= 8) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    setState(() => _passwordStrength = strength);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text,
        _passwordController.text,
        _isSignUp ? _nameController.text : null,
        _isSignUp ? _phoneController.text : null,
      );
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
