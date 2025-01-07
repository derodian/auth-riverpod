import 'package:flutter/material.dart';

class PasswordRequirement extends StatelessWidget {
  const PasswordRequirement({
    super.key,
    required this.isValid,
    required this.text,
  });

  final bool isValid;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  final double strength; // 0.0 to 1.0

  String get _strengthText {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.7) return 'Medium';
    return 'Strong';
  }

  Color get _strengthColor {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
        ),
        const SizedBox(height: 4),
        Text(
          _strengthText,
          style: TextStyle(
            color: _strengthColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
