import 'package:auth_riverpod/src/features/splash/presentation/splash_screen.dart';
import 'package:auth_riverpod/src/features/home/presentation/home_screen.dart';
import 'package:auth_riverpod/src/features/on_boarding/data/onboarding_repository.dart';
import 'package:auth_riverpod/src/features/on_boarding/presentation/onboarding_controller.dart';
import 'package:auth_riverpod/src/features/on_boarding/presentation/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
Raw<GoRouter> goRouter(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final onboardingComplete = ref.watch(onboardingControllerProvider);

          // Show splash screen while repositories are initializing
          if (ref.watch(onboardingRepositoryProvider).isLoading) {
            return const SplashScreen();
          }

          if (!onboardingComplete) {
            return const OnboardingScreen();
          }

          return const HomeScreen();
        },
      ),
      // Other routes that don't need auth checks

      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      // ... other routes
    ],
    redirect: (context, state) {
      return null;
    },
  );
}
