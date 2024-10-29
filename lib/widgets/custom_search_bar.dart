import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {

  String hintText;

  CustomSearchBar({super.key, required this.hintText });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: double.infinity,
      child: SearchBar(leading: Icon(Icons.search,),
        hintText: "Search",
      ),
    );
  }
}
