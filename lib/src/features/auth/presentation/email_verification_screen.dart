import 'dart:async';

import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/presentation/email_verification_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// class EmailVerificationScreen extends ConsumerStatefulWidget {
//   const EmailVerificationScreen({super.key});

//   @override
//   ConsumerState<EmailVerificationScreen> createState() =>
//       _EmailVerificationScreenState();
// }

// class _EmailVerificationScreenState
//     extends ConsumerState<EmailVerificationScreen> {
//   bool _canResendEmail = true;
//   late Stream<bool> _isVerified;
//   Timer? _timer;
//   bool _mounted = true;

//   @override
//   void initState() {
//     super.initState();
//     _setupEmailVerificationListener();
//     _startVerificationCheck();
//   }

//   @override
//   void dispose() {
//     _mounted = false;
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _setupEmailVerificationListener() {
//     _isVerified.listen((isVerified) {
//       if (isVerified && mounted) {
//         ref.read(routerControllerProvider.notifier).goToWaitingApproval();
//       }
//     });
//   }

//   void _startVerificationCheck() {
//     // Initial check
//     _checkEmailVerification();

//     // Set up periodic check
//     _timer = Timer.periodic(const Duration(seconds: 5), (_) {
//       _checkEmailVerification();
//     });
//   }

//   Future<void> _checkEmailVerification() async {
//     if (!_mounted) return;

//     try {
//       await ref.read(authControllerProvider.notifier).reload();

//       if (!_mounted) return;

//       final user = ref.read(authControllerProvider).valueOrNull;
//       if (user?.isEmailVerified ?? false) {
//         _timer?.cancel();
//         if (_mounted) {
//           ref.read(routerControllerProvider.notifier).goToWaitingApproval();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error checking email verification: $e');
//     }
//   }

//   Future<void> _sendVerificationEmail() async {
//     if (!_canResendEmail) return;

//     setState(() => _canResendEmail = false);

//     try {
//       await ref.read(authControllerProvider.notifier).sendEmailVerification();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Verification email sent!'),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }

//     // Allow resending after 30 seconds
//     Future.delayed(const Duration(seconds: 30), () {
//       if (mounted) {
//         setState(() => _canResendEmail = true);
//       }
//     });
//   }

//   Future<void> _refresh() async {
//     await ref.read(authControllerProvider.notifier).reload();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authControllerProvider);

//     return AsyncValueListener<void>(
//       value: authState.isLoading ? const AsyncLoading() : const AsyncData(null),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Verify Your Email'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: () async {
//                 await ref.read(authControllerProvider.notifier).signOut();
//                 if (mounted) {
//                   ref.read(routerControllerProvider.notifier).goToAuth();
//                 }
//               },
//             ),
//           ],
//         ),
//         body: RefreshIndicator(
//           onRefresh: _checkEmailVerification,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               const Icon(
//                 Icons.mark_email_unread_outlined,
//                 size: 100,
//                 color: Colors.blue,
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Verify Your Email',
//                 style: Theme.of(context).textTheme.headlineMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'We\'ve sent you an email verification link. Please check your email and click the link to verify your account.',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _canResendEmail ? _sendVerificationEmail : null,
//                 child: Text(_canResendEmail
//                     ? 'Resend Verification Email'
//                     : 'Wait 30 seconds...'),
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: _refresh,
//                 child: const Text('I\'ve verified my email'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _canResendEmail = true;
  bool _isLoading = false;
  Timer? _resendTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Delay initial check to avoid build-time conflicts
    Future(() => ref
        .read(emailVerificationControllerProvider.notifier)
        .startVerificationCheck());
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _remainingSeconds = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _canResendEmail = true);
      }
    });
  }

  String _getTimeRemaining() => _remainingSeconds.toString();

  Future<void> _sendVerificationEmail() async {
    if (!_canResendEmail || _isLoading) return;

    setState(() {
      _isLoading = true;
      _canResendEmail = false;
    });

    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerification();
      _showMessage('Verification email sent!', isError: false);
      _startResendTimer();
    } catch (e) {
      _showMessage(e.toString(), isError: true);
      setState(() => _canResendEmail = true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) {
        ref.read(routerControllerProvider.notifier).goToAuth();
      }
    } catch (e) {
      _showMessage('Failed to sign out: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Use AsyncValue.guard to handle navigation
    ref.listen<AsyncValue<AppUser?>>(
      authControllerProvider,
      (_, next) {
        next.whenData((user) {
          if (user?.isEmailVerified ?? false) {
            ref.read(routerControllerProvider.notifier).goToWaitingApproval();
          }
        });
      },
    );

    return Scaffold(
      body: authState.when(
        data: (_) => Stack(
          children: [
            _buildContent(),
            Positioned(
              top: 16 + MediaQuery.of(context).padding.top,
              right: 16,
              child: IconButton.filled(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
              ),
            ),
          ],
        ),
        error: (error, _) => _buildErrorState(error),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(emailVerificationControllerProvider.notifier)
              .checkVerification(showError: true),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent you an email verification link. Please check your email and click the link to verify your account.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: (_canResendEmail && !_isLoading)
                    ? _sendVerificationEmail
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_canResendEmail
                    ? 'Resend Verification Email'
                    : 'Wait ${_getTimeRemaining()} seconds...'),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => ref
                    .read(emailVerificationControllerProvider.notifier)
                    .checkVerification(showError: true),
                icon: const Icon(Icons.refresh),
                label: const Text('I\'ve verified my email'),
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
                  .read(emailVerificationControllerProvider.notifier)
                  .checkVerification(showError: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
