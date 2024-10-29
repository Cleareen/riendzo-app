import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final dynamic leadingIcon, textTitle, trailingIcon, onTap;
  const ProfileCard({
    super.key,
    this.leadingIcon,
    this.textTitle,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap,
      child: Card(
        elevation: 0,
        child: ListTile(
          leading: leadingIcon,
          title: Text('$textTitle'),
          trailing: Icon(trailingIcon),
        ),
      ),
    );
  }
}
