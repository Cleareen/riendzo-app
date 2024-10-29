import 'package:flutter/material.dart';
import 'package:riendzo/widgets/trip_card.dart';

class ongoing_trips_settings extends StatelessWidget {
  const ongoing_trips_settings({super.key});

  @override
  Widget build(BuildContext context) {
    return trip_card(
      image_height: 200.0,
      radius: 10.0,
      country: "South Africa",
      location: "Graskop",
      start_date: "12 FEB",
      end_date: "14 FEB",
      images_of_users_booked1:
          "https://images.pexels.com/photos/8974087/pexels-photo-8974087.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      images_of_users_booked2:
          "https://images.pexels.com/photos/8974087/pexels-photo-8974087.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      images_of_users_booked3:
          "https://images.pexels.com/photos/8974087/pexels-photo-8974087.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      picture:
          "https://images.pexels.com/photos/8974087/pexels-photo-8974087.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    );
  }
}
