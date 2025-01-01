import 'package:auth_riverpod/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase here if needed
  runApp(const ProviderScope(child: MyApp()));
}
