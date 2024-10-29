import 'package:flutter/material.dart';

class Sections extends StatelessWidget {
  final String sectionName, trailingText;
  final double veritcalMargin;

  Sections({super.key, required this.sectionName, required this.trailingText, required this.veritcalMargin});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin:
              EdgeInsets.symmetric(horizontal: 10, vertical:veritcalMargin!, ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                trailingText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
