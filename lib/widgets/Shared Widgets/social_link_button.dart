import 'package:flutter/material.dart';

class SocialLinkButton extends StatelessWidget {
  Function function;
  IconData icon;
  Color iconColor;

  SocialLinkButton({
    super.key,
    required this.function,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        onPressed: function(),
        icon: Icon(icon, color: iconColor),
        iconSize: 40,
      ),
    );
  }
}
