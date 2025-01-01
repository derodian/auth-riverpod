import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:auth_riverpod/src/theme/app_theme_data.dart';
import 'package:auth_riverpod/src/theme/app_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(appThemeModeNotifierProvider);
    print('=== Building MyApp ===');
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.light(),
      darkTheme: AppThemeData.dark(),
      themeMode: themeMode,
      routerConfig: router,
      title: 'Auth Riverpod',
    );
  }
}
