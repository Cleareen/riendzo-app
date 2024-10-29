import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  final double horizontalPadding, TextSize;
  final Color cardColor, textColor;
  final String text;
  final Function? onPressed;
  final Widget? child;

  CustomButton({
    super.key,
    required this.cardColor,
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.horizontalPadding,
    required this.TextSize,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      elevation: 0,
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              MediaQuery.of(context).size.width * horizontalPadding / 100,
        ),
        child: TextButton(
          onPressed: () {
            onPressed!();
          },
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: TextSize,
            ),
          ),
        ),
      ),
    );
  }
}
