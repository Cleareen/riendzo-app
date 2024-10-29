import 'package:flutter/material.dart';

class IconTextRow extends StatelessWidget {
  IconData icon;
  int IconSize;
  String text;
  Color color;

  IconTextRow({
    super.key,
    required this.icon,
    required this.IconSize,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: IconSize * 1.0,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 15),
        )
      ],
    );
  }
}
