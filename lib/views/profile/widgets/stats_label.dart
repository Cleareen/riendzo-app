import 'package:flutter/material.dart';
import 'package:riendzo/theme/theme.dart';

class ProfileStatsLabel extends StatelessWidget {
  final dynamic dataValue;
  final dynamic dataLabel;

  const ProfileStatsLabel({super.key, value, label, this.dataValue, this.dataLabel});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$dataValue'!,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: lightColorScheme.primary),
        ),
        Text(
          dataLabel!,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}
