import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailReauthenticationDialog extends ConsumerStatefulWidget {
  final String email;
  final Future<void> Function(String password) onSubmit;

  const EmailReauthenticationDialog({
    super.key,
    required this.email,
    required this.onSubmit,
  });

  static Future<bool> show(
    BuildContext context, {
    required String email,
    required Future<void> Function(String password) onSubmit,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmailReauthenticationDialog(
        email: email,
        onSubmit: onSubmit,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<EmailReauthenticationDialog> createState() =>
      _EmailReauthenticationDialogState();
}

class _EmailReauthenticationDialogState
    extends ConsumerState<EmailReauthenticationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isAuthenticating = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAuthenticating = true);

    try {
      await widget.onSubmit(_passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAuthenticating = false);
      // Error is handled by the onSubmit callback
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Your Password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Please enter your password to confirm deletion of ${widget.email}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              enabled: !_isAuthenticating,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              onFieldSubmitted: (value) => _handleSubmit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isAuthenticating ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isAuthenticating ? null : _handleSubmit,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: _isAuthenticating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm & Delete'),
        ),
      ],
    );
  }
}
