import 'package:flutter/material.dart';
import 'package:riendzo/widgets/Shared%20Widgets/icon_text_row.dart';

import '../Mock Data/featured_experience.dart';

class FeaturedExperienceCard extends StatelessWidget {
  List picture1, picture2, picture3, activity, location, country;
  int height, width;

  FeaturedExperienceCard({
    super.key,
    required this.height,
    required this.width,
    required this.picture1,
    required this.picture2,
    required this.picture3,
    required this.activity,
    required this.location,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 1.0,
      child: ListView.builder(
        itemCount: featuredExperiences.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return SizedBox(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 200,
                        width: 203,
                        decoration: BoxDecoration(borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                        ),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                              picture1[index][3],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  picture1[index][4],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  picture1[index][5],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: width * 1.0,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                activity[index][0],
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                location[index][1],
                              ),
                              IconTextRow(
                                icon: Icons.location_on,
                                IconSize: 15,
                                text: country[index][2],
                                color: Colors.blueAccent,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
