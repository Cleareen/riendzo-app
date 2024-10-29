import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  double size;
  String picture;

  UserAvatar({
    super.key,
    required this.size,
    required this.picture,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundImage: NetworkImage(
        picture,
      ),
    );
  }
}
