import 'package:flutter/material.dart';

class trip_card extends StatelessWidget {
  double image_height;
  double radius;
  String picture;
  String location;
  String country;
  String images_of_users_booked1;
  String images_of_users_booked2;
  String images_of_users_booked3;
  String start_date;
  String end_date;

  trip_card({
    super.key,
    required this.radius,
    required this.picture,
    required this.location,
    required this.country,
    required this.start_date,
    required this.end_date,
    required this.images_of_users_booked1,
    required this.images_of_users_booked2,
    required this.images_of_users_booked3,
    required this.image_height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child: SizedBox(
        width: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$start_date - $end_date,",style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      ),
                      const Text(
                        "10 People Interest",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
