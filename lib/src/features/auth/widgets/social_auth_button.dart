import 'package:auth_riverpod/src/features/auth/domain/app_user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum SocialButtonSize {
  small,
  large,
}

class SocialAuthButton extends StatelessWidget {
  final AppAuthProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final SocialButtonSize size;
  final double? width;
  final double? height;

  const SocialAuthButton({
    Key? key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.size = SocialButtonSize.large,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return size == SocialButtonSize.small
        ? _buildSmallButton(context)
        : _buildLargeButton(context);
  }

  Widget _buildSmallButton(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FaIcon(
              _getProviderIcon(),
              size: 24,
              color: isDark ? Colors.white : _getProviderColor(),
            ),
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
      tooltip: _getButtonText(), // Add tooltip for accessibility
    );
  }

  Widget _buildLargeButton(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FaIcon(
                      _getProviderIcon(),
                      size: 20,
                      color: isDark ? Colors.white : _getProviderColor(),
                    ),
              label: Text(_getButtonText()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.white54 : Colors.grey.shade300,
                ),
                foregroundColor: isDark ? Colors.white : _getProviderColor(),
              ),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FaIcon(_getProviderIcon(), size: 20),
              label: Text(_getButtonText()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getProviderColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
    );
  }

  IconData _getProviderIcon() {
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

  String _getButtonText() {
    switch (provider) {
      case AppAuthProvider.google:
        return 'Continue with Google';
      case AppAuthProvider.apple:
        return 'Continue with Apple';
      case AppAuthProvider.facebook:
        return 'Continue with Facebook';
      case AppAuthProvider.github:
        return 'Continue with GitHub';
      default:
        return 'Continue with Email';
    }
  }

  Color _getProviderColor() {
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
