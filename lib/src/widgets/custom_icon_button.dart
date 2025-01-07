import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.black54,
    this.iconColor = Colors.white,
    this.size = 40.0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: size / 2,
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onPressed,
          iconSize: size * 0.5,
        ),
      ),
    );
  }
}
