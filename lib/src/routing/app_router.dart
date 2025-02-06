import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/features/auth/presentation/auth_screen.dart';
import 'package:auth_riverpod/src/features/auth/presentation/email_verification_screen.dart';
import 'package:auth_riverpod/src/features/auth/presentation/waiting_approval_screen.dart';
import 'package:auth_riverpod/src/features/error/error_screen.dart';
import 'package:auth_riverpod/src/features/loading/presentation/loading_screen.dart';
import 'package:auth_riverpod/src/features/home/presentation/home_screen.dart';
import 'package:auth_riverpod/src/features/on_boarding/presentation/onboarding_controller.dart';
import 'package:auth_riverpod/src/features/on_boarding/presentation/onboarding_screen.dart';
// import 'package:auth_riverpod/src/features/on_boarding/presentation/onboarding_screen.dart';
// import 'package:auth_riverpod/src/routing/go_router_refresh_stream.dart';
// import 'package:auth_riverpod/src/routing/not_found_screen.dart';
// import 'package:auth_riverpod/src/routing/scaffold_with_nested_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      final onboardingComplete = ref.watch(onboardingControllerProvider);
      final authState = ref.watch(authControllerProvider);

      final authController = ref.read(authControllerProvider.notifier);

      // Skip redirection if reathenticating
      if (authController.isReauthenticating) {
        return null;
      }

      // Get the current path
      final currentPath = state.matchedLocation;

      RouterLogger.logInfo('Checking redirect for path: $currentPath');
      RouterLogger.logInfo('Auth state: ${authState.toString()}');
      RouterLogger.logInfo('Onboarding complete: $onboardingComplete');

      // Handle loading state
      if (authState.isLoading) {
        RouterLogger.logRedirect(currentPath, null);
        return null;
      }

      // Check if user is on specific routes
      final isOnboardingRoute = currentPath == '/onboarding';
      final isAuthRoute = currentPath == '/auth';
      final isVerificationRoute = currentPath == '/verify-email';
      final isApprovalRoute = currentPath == '/waiting-approval';

      // // Don't redirect during loading or error states if we're on a valid screen
      // if (authState.isLoading || authState.hasError) {
      //   if (isAuthRoute || isVerificationRoute || isApprovalRoute) {
      //     return null;
      //   }
      // }

      // Check onboarding first
      if (!onboardingComplete) {
        // If already on onboarding, don't redirect
        if (isOnboardingRoute) {
          return null;
        }
        // If not on onboarding, redirect to it
        return '/onboarding';
      }

      // Only handle authentication states, ignore error states
      if (authState.hasValue && !authState.hasError) {
        final user = authState.value;

        // If no user, redirect to auth unless already there
        if (user == null && !isAuthRoute) {
          RouterLogger.logRedirect(currentPath, '/auth');
          return '/auth';
        }

        // If we have a user
        if (user != null) {
          // Don't redirect if already on the correct screen
          if (!user.isEmailVerified && !isVerificationRoute) {
            RouterLogger.logRedirect(currentPath, '/verify-email');
            return '/verify-email';
          }

          if (user.isEmailVerified &&
              !user.isAdminApproved &&
              !isApprovalRoute) {
            RouterLogger.logRedirect(currentPath, '/waiting-approval');
            return '/waiting-approval';
          }

          // If user is fully verified and approved, send to home
          if (user.isEmailVerified &&
              user.isAdminApproved &&
              currentPath == '/') {
            RouterLogger.logRedirect(currentPath, '/home');
            return '/home';
          }
        }
      }

      // If we're at root and not authenticated, go to auth
      if (currentPath == '/' && !authState.isLoading) {
        RouterLogger.logRedirect(currentPath, '/auth');
        return '/auth';
      }

      // No redirect needed
      RouterLogger.logRedirect(currentPath, null);
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) => ErrorScreen(
          error: state.extra?.toString() ?? 'An unknown error occurred',
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/waiting-approval',
        builder: (context, state) => const WaitingApprovalScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      // Add other routes as needed
    ],
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error.toString(),
    ),
  );
}

// Optional: Add extension methods for common routing operations
extension GoRouterX on GoRouter {
  void goToAuth() => go('/auth');
  void goToHome() => go('/home');
  void goToOnboarding() => go('/onboarding');
  void goToEmailVerification() => go('/verify-email');
  void goToWaitingApproval() => go('/waiting-approval');
}

// Optional: Add a provider for easy access to router methods
@riverpod
class RouterController extends _$RouterController {
  @override
  void build() {}

  void goToAuth() => ref.read(goRouterProvider).goToAuth();
  void goToHome() => ref.read(goRouterProvider).goToHome();
  void goToOnboarding() => ref.read(goRouterProvider).goToOnboarding();
  void goToEmailVerification() =>
      ref.read(goRouterProvider).goToEmailVerification();
  void goToWaitingApproval() =>
      ref.read(goRouterProvider).goToWaitingApproval();
}

// Add a more detailed logging utility
class RouterLogger {
  static void logRedirect(String? from, String? to, {Object? extra}) {
    if (to == null) return;
    debugPrint('🚦 Router Redirect:'
        '\n   From: $from'
        '\n   To: $to'
        '${extra != null ? '\n   Extra: $extra' : ''}');
  }

  static void logError(String message, Object error) {
    debugPrint('❌ Router Error:'
        '\n   Message: $message'
        '\n   Error: $error');
  }

  static void logInfo(String message) {
    debugPrint('ℹ️ Router Info: $message');
  }
}
