import 'package:flutter/material.dart';
import 'package:riendzo/widgets/custom_icon.dart';

class ButtonWithIcon extends StatelessWidget {
  final double horizontalPadding, verticalPadding, TextSize;
  final Color cardColor, textColor;
  final String text;
  final Function? onPressed;
  final dynamic iconData, iconColor;

  ButtonWithIcon({
    super.key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.cardColor,
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.TextSize,
    this.iconData,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              MediaQuery.of(context).size.width * horizontalPadding / 100,
          vertical: MediaQuery.of(context).size.width * verticalPadding/7/ 100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIcon(
              icon: iconData,
              color: iconColor,
            ),
            TextButton(
              onPressed: (){
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
          ],
        ),
      ),
    );
  }
}
