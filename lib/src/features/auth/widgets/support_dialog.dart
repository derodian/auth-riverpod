import 'package:auth_riverpod/src/util/url_launcher_utils.dart';
import 'package:flutter/material.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({
    super.key,
    required this.adminEmail,
    required this.supportPhone,
    required this.emailBody,
  });

  final String adminEmail;
  final String supportPhone;
  final String emailBody;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Contact Support'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Send Email'),
            subtitle: Text(adminEmail),
            onTap: () {
              Navigator.pop(context);
              context.launchEmail(
                adminEmail,
                subject: 'Account Approval Request',
                body: emailBody,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Contact Support'),
            subtitle: Text(supportPhone),
            onTap: () {
              Navigator.pop(context);
              context.launchPhone(supportPhone);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// In WaitingApprovalScreen:
// void _showSupportDialog() {
//   final controller = ref.read(waitingApprovalControllerProvider.notifier);
//   showDialog(
//     context: context,
//     builder: (_) => SupportDialog(
//       adminEmail: controller.getAdminEmail(),
//       supportPhone: controller.getSupportPhone(),
//       emailBody: controller.getEmailBody(),
//     ),
//   );
// }
