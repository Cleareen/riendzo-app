import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:riendzo/widgets/custom_icon.dart';
import 'package:riendzo/widgets/liked_users_stacked_avatars.dart';

class PastTripCard extends StatelessWidget {
  var image1;
  var image2;
  var image3;
  var image4;
  var location;
  var year;
  var country;
  var price;
  var no_of_days;
  var images_of_users_booked1;
  var images_of_users_booked2;
  var images_of_users_booked3;
  var images_of_users_liked1;
  var images_of_users_liked2;
  var images_of_users_liked3;
  var top_user_liked;
  var no_of_likes;

  PastTripCard({
    super.key,
    @required this.image1,
    @required this.image2,
    @required this.image3,
    @required this.image4,
    @required this.location,
    @required this.year,
    @required this.country,
    @required this.price,
    @required this.no_of_days,
    @required this.images_of_users_booked1,
    @required this.images_of_users_booked2,
    @required this.images_of_users_booked3,
    @required this.images_of_users_liked1,
    @required this.images_of_users_liked2,
    @required this.images_of_users_liked3,
    @required this.top_user_liked,
    @required this.no_of_likes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 205,
                width: 145,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                      image1,
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
                          image2,
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
                              image3,
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
                              image4,
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
            margin: const EdgeInsets.all(10),
            width: 310,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "In $location , $year",
                      style: const TextStyle(fontSize: 15),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blueAccent,
                          size: 15,
                        ),
                        Text(
                          country,
                          style: const TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                  ],
                ),
                Container(
                  color: Colors.grey,
                  height: 1,
                  width: 300,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Row(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          top_user_liked,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('and '),
                        Text(
                          no_of_likes,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(' others'),
                        StackedAvatars(
                          usersLikedAvatar1:
                              "https://images.pexels.com/photos/5615665/pexels-photo-5615665.jpeg?auto=compress&cs=tinysrgb&w=1600",
                          usersLikedAvatar2:
                              "https://images.pexels.com/photos/7275385/pexels-photo-7275385.jpeg?auto=compress&cs=tinysrgb&w=1600",
                          usersLikedAvatar3:
                              "https://images.pexels.com/photos/5792641/pexels-photo-5792641.jpeg?auto=compress&cs=tinysrgb&w=1600",
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
  }
}
