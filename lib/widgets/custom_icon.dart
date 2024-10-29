import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  var icon, color, iconSize;

  CustomIcon({
    super.key,
    @required this.icon,
    @required this.color,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: iconSize,
    );
  }
}
