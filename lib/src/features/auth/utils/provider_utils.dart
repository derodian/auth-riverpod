import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProviderUtils {
  static IconData getProviderIcon(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        return FontAwesomeIcons.google;
      case AppAuthProvider.apple:
        return FontAwesomeIcons.apple;
      case AppAuthProvider.facebook:
        return FontAwesomeIcons.facebookF;
      case AppAuthProvider.github:
        return FontAwesomeIcons.github;
      default:
        return FontAwesomeIcons.envelope;
    }
  }

  static String getProviderName(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        return 'Google';
      case AppAuthProvider.apple:
        return 'Apple';
      case AppAuthProvider.facebook:
        return 'Facebook';
      case AppAuthProvider.github:
        return 'GitHub';
      default:
        return 'Email';
    }
  }

  static Color getProviderColor(AppAuthProvider provider) {
    switch (provider) {
      case AppAuthProvider.google:
        return const Color(0xFFDB4437);
      case AppAuthProvider.apple:
        return const Color(0xFF000000);
      case AppAuthProvider.facebook:
        return const Color(0xFF1877F2);
      case AppAuthProvider.github:
        return const Color(0xFF333333);
      default:
        return Colors.blue;
    }
  }
}
