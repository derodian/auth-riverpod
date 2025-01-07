// lib/features/auth/screens/auth_screen.dart
import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/enum/auth_form_type.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/presentation/email_password_form.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthFormType _formType = AuthFormType.signIn;

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

  Future<void> _onSubmit(
    String email,
    String password, [
    String? name,
    String? phone,
  ]) async {
    try {
      if (_formType.isSignIn) {
        await ref.read(authControllerProvider.notifier).signIn(
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FlutterLogo(size: 100),
                  const SizedBox(height: 32),
                  Text(
                    _formType.isSignIn
                        ? 'Welcome Back!'
                        : _formType.isSignUp
                            ? 'Create Account'
                            : 'Reset Password',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  EmailPasswordForm(
                    formType: _formType,
                    onSubmit: _onSubmit,
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  if (!_formType.isForgotPassword)
                    TextButton(
                      onPressed: authState.isLoading ? null : _toggleFormType,
                      child: Text(
                        _formType.isSignIn
                            ? 'Need an account? Sign up'
                            : 'Have an account? Sign in',
                      ),
                    ),
                  if (_formType.isSignIn)
                    TextButton(
                      onPressed:
                          authState.isLoading ? null : _showForgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  if (_formType.isForgotPassword)
                    TextButton(
                      onPressed: authState.isLoading ? null : _toggleFormType,
                      child: const Text('Have an account? Sign in'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
