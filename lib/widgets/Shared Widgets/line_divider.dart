import 'package:flutter/material.dart';

class LineDvider extends StatelessWidget {
  int screenWidthPercentage;
  Color color;

  LineDvider({super.key, required this.screenWidthPercentage, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: MediaQuery.of(context).size.width * screenWidthPercentage/100,
      color: color,
    );
  }
}
