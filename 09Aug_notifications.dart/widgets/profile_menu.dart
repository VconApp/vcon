//profile_menu.dart
import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.icon,
    this.press,
    this.badge,
  });

  final String text;
  final Icon icon;
  final VoidCallback? press;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20, 
        vertical: 10
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 69, 116, 197), padding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            icon, // Use the passed icon directly
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text
              ),
            ),
            if (badge != null) badge!,
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}