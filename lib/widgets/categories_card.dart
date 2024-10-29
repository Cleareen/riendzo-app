import 'dart:ui';

import 'package:flutter/material.dart';

import '../Mock Data/storiesBank.dart';

class CategoriesCard extends StatelessWidget {
  int height, width;
  String pictures;
  List category;

  CategoriesCard({
    super.key,
    required this.height,
    required this.width,
    required this.pictures,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height*1.0,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(

              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return InkWell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Stack(
                        children: [
                          Image.network(
                            pictures,
                            fit: BoxFit.fill,
                            height: height * 1.0,
                            width: width * 1.0,
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 0,
                                  sigmaY: 1,
                                  tileMode: TileMode.mirror),
                              child: Center(
                                child: Text(
                                  category[index],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
