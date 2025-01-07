import 'dart:async';

import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:auth_riverpod/src/widgets/async_value_listner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _canResendEmail = true;
  late final Stream<bool> _isVerified;
  Timer? _timer;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _setupEmailVerificationListener();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _mounted = false;
    _timer?.cancel();
    super.dispose();
  }

  void _setupEmailVerificationListener() {
    _isVerified.listen((isVerified) {
      if (isVerified && mounted) {
        ref.read(routerControllerProvider.notifier).goToWaitingApproval();
      }
    });
  }

  void _startVerificationCheck() {
    // Initial check
    _checkEmailVerification();

    // Set up periodic check
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    if (!_mounted) return;

    try {
      await ref.read(authControllerProvider.notifier).reload();

      if (!_mounted) return;

      final user = ref.read(authControllerProvider).valueOrNull;
      if (user?.isEmailVerified ?? false) {
        _timer?.cancel();
        if (_mounted) {
          ref.read(routerControllerProvider.notifier).goToWaitingApproval();
        }
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
    }
  }

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail) return;

    setState(() => _canResendEmail = false);

    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Allow resending after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _canResendEmail = true);
      }
    });
  }

  Future<void> _refresh() async {
    await ref.read(authControllerProvider.notifier).reload();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AsyncValueListener<void>(
      value: authState.isLoading ? const AsyncLoading() : const AsyncData(null),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Your Email'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (mounted) {
                  ref.read(routerControllerProvider.notifier).goToAuth();
                }
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _checkEmailVerification,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We\'ve sent you an email verification link. Please check your email and click the link to verify your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canResendEmail ? _sendVerificationEmail : null,
                child: Text(_canResendEmail
                    ? 'Resend Verification Email'
                    : 'Wait 30 seconds...'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _refresh,
                child: const Text('I\'ve verified my email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
