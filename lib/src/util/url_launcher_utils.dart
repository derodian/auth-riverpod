import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherResult {
  const UrlLauncherResult._({
    required this.success,
    this.error,
  });

  final bool success;
  final String? error;

  // Static instances
  static const UrlLauncherResult successResult =
      UrlLauncherResult._(success: true);

  // Factory constructor for success
  factory UrlLauncherResult.success() => successResult;

  // Factory constructor for error
  factory UrlLauncherResult.error(String message) =>
      UrlLauncherResult._(success: false, error: message);
}

enum PhoneAction {
  call,
  message;

  String get label => switch (this) {
        PhoneAction.call => 'Call',
        PhoneAction.message => 'Message',
      };

  IconData get icon => switch (this) {
        PhoneAction.call => Icons.phone,
        PhoneAction.message => Icons.message,
      };
}

class UrlLauncherUtils {
  static Future<UrlLauncherResult> openPhone(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      final action = await _showPhoneActionDialog(context);
      if (action == null || !context.mounted) {
        return UrlLauncherResult.error('Action cancelled');
      }

      final url = switch (action) {
        PhoneAction.call => 'tel:$phoneNumber',
        PhoneAction.message => 'sms:$phoneNumber',
      };

      return await _launchUrl(url);
    } catch (e) {
      return UrlLauncherResult.error(e.toString());
    }
  }

  static Future<UrlLauncherResult> openEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );

      return await _launchUrl(emailLaunchUri.toString());
    } catch (e) {
      return UrlLauncherResult.error(e.toString());
    }
  }

  static Future<UrlLauncherResult> openMap(String address) async {
    try {
      // Try Google Maps first
      final googleUrl =
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
      final googleMapsResult = await _launchUrl(googleUrl);
      if (googleMapsResult.success) {
        return googleMapsResult;
      }

      // Fallback to Apple Maps on iOS
      final appleUrl = 'maps://?q=${Uri.encodeComponent(address)}';
      final appleMapsResult = await _launchUrl(appleUrl);
      if (appleMapsResult.success) {
        return appleMapsResult;
      }

      // Final fallback to browser
      final browserUrl =
          'https://maps.google.com/?q=${Uri.encodeComponent(address)}';
      return await _launchUrl(browserUrl);
    } catch (e) {
      return UrlLauncherResult.error(e.toString());
    }
  }

  static Future<UrlLauncherResult> openWebUrl(String url) async {
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      return await _launchUrl(url);
    } catch (e) {
      return UrlLauncherResult.error(e.toString());
    }
  }

  static Future<PhoneAction?> _showPhoneActionDialog(
      BuildContext context) async {
    return showDialog<PhoneAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact via'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PhoneAction.values.map((action) {
            return ListTile(
              leading: Icon(action.icon),
              title: Text(action.label),
              onTap: () => Navigator.of(context).pop(action),
            );
          }).toList(),
        ),
      ),
    );
  }

  static Future<UrlLauncherResult> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        return launched
            ? UrlLauncherResult.success()
            : UrlLauncherResult.error('Failed to launch URL');
      }
      return UrlLauncherResult.error('Cannot launch URL: $url');
    } catch (e) {
      return UrlLauncherResult.error(e.toString());
    }
  }
}

// Extension for showing snackbars
extension SnackBarX on BuildContext {
  void showErrorSnackBar(String message) {
    print(message);
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// URL Launcher extensions
extension UrlLauncherUtilsX on BuildContext {
  Future<void> launchPhone(String phone) async {
    final result = await UrlLauncherUtils.openPhone(this, phone);
    if (mounted) {
      if (result.success) {
        showSuccessSnackBar('Launching phone action...');
      } else {
        showErrorSnackBar(result.error ?? 'Failed to launch phone action');
      }
    }
  }

  Future<void> launchEmail(String email,
      {String? subject, String? body}) async {
    final result = await UrlLauncherUtils.openEmail(
      email,
      subject: subject,
      body: body,
    );
    if (mounted) {
      if (result.success) {
        showSuccessSnackBar('Opening email...');
      } else {
        showErrorSnackBar(result.error ?? 'Failed to launch email');
      }
    }
  }

  Future<void> launchMap(String address) async {
    final result = await UrlLauncherUtils.openMap(address);
    if (mounted) {
      if (result.success) {
        showSuccessSnackBar('Opening map...');
      } else {
        showErrorSnackBar(result.error ?? 'Failed to open map');
      }
    }
  }

  Future<void> launchWeb(String url) async {
    final result = await UrlLauncherUtils.openWebUrl(url);
    if (mounted) {
      if (result.success) {
        showSuccessSnackBar('Opening website...');
      } else {
        showErrorSnackBar(result.error ?? 'Failed to open URL');
      }
    }
  }
}
