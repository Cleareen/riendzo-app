import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:riendzo/Mock%20Data/top_trips.dart';
import 'package:riendzo/widgets/custom_icon.dart';
import 'package:riendzo/widgets/Shared%20Widgets/icon_text_row.dart';
import 'package:riendzo/widgets/liked_users_stacked_avatars.dart';
import 'Shared Widgets/user_avatar.dart';

class StackedImageCard extends StatelessWidget {
  final int noLikes, year, noDays, height, noPeople;
  final double usersLikedAvatarsSize, price;
  final String topUserLiked;
  final List image1,
      image2,
      image3,
      image4,
      location,
      country,
      imageUsersBooked1,
      imageUsersBooked2,
      imageUsersBooked3,
      imageUserLiked1,
      imageUserLiked2,
      imageUserLiked3;

  const StackedImageCard(
      {super.key,
      required this.height,
      required this.image1,
      required this.image2,
      required this.image3,
      required this.image4,
      required this.location,
      required this.noPeople,
      required this.year,
      required this.country,
      required this.price,
      required this.noDays,
      required this.imageUsersBooked1,
      required this.imageUsersBooked2,
      required this.imageUsersBooked3,
      required this.imageUserLiked1,
      required this.imageUserLiked2,
      required this.imageUserLiked3,
      required this.topUserLiked,
      required this.noLikes,
      required this.usersLikedAvatarsSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 1.0,
      child: ListView.builder(
        itemCount: places.length,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 205,
                      width: 160,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                        ),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                            image1[index][0],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          height: 110,
                          width: 185,
                          margin: const EdgeInsets.only(left: 3, bottom: 3),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                            ),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                image2[index][1],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 90,
                              width: 90,
                              margin: const EdgeInsets.only(left: 3, top: 3),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    image3[index][2],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 90,
                              width: 90,
                              margin: const EdgeInsets.only(left: 6, top: 3),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(5),
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                    image4[index][3],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 350,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "In ${location[index]} , $year",
                              style: const TextStyle(fontSize: 15),
                            ),
                            IconTextRow(
                              icon: Icons.location_on,
                              IconSize: 15,
                              text: location[index],
                              color: Colors.blueAccent,
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 345,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Card(
                                        color: Colors.deepOrange,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text("R $price"),
                                        ),
                                      ),
                                      Text(
                                        "$noDays Days",
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "($noPeople People booked)",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                UserAvatar(
                                  size: usersLikedAvatarsSize / 1000,
                                  picture: imageUsersBooked1[index],
                                ),
                                UserAvatar(
                                  size: usersLikedAvatarsSize / 1000,
                                  picture: imageUsersBooked2[index],
                                ),
                                UserAvatar(
                                  size: usersLikedAvatarsSize / 1000,
                                  picture: imageUsersBooked3[index],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        height: 1,
                        width: 345,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomIcon(
                                color: Colors.grey,
                                icon: Ionicons.heart_outline,
                              ),
                              CustomIcon(
                                color: Colors.grey,
                                icon: Icons.comment_outlined,
                              ),
                              CustomIcon(
                                color: Colors.grey,
                                icon: Icons.send_outlined,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CustomIcon(
                                color: Colors.grey,
                                icon: Ionicons.bookmark_outline,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text('Liked by '),
                              Text(
                                topUserLiked,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text('and '),
                              Text(
                                "$noLikes",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text(' others'),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: StackedAvatars(
                                  usersLikedAvatar1: imageUserLiked1[index],
                                  usersLikedAvatar2: imageUserLiked2[index],
                                  usersLikedAvatar3: imageUserLiked3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
