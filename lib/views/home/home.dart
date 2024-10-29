import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Mock Data/ProfilePictures.dart';
import '../../Mock Data/catergories.dart';
import '../../Mock Data/featured_experience.dart';
import '../../Mock Data/hot_places.dart';
import '../../Mock Data/top_trips.dart';
import '../../widgets/Shared Widgets/avatars_row.dart';
import '../../widgets/Shared Widgets/feed_app_bar.dart';
import '../../widgets/Shared Widgets/home_avatars_row.dart';
import '../../widgets/Shared Widgets/one_image_card.dart';
import '../my_trips/trip_details.dart';
import '../../widgets/Shared Widgets/user_avatar.dart';
import '../../widgets/categories_card.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/featured_experience_card.dart';
import '../../widgets/screen_sections.dart';
import '../../widgets/stacked_image_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(15),

          children: [
            Sections(
              sectionName: "Where do you\nWant to travel?",
              trailingText: "",
              veritcalMargin: 15,
            ),
            CustomSearchBar(
              hintText: "Search",
            ),
            const SizedBox(height: 40),
            Sections(
              sectionName: "Categories",
              trailingText: "",
              veritcalMargin: 10,
            ),
            CategoriesCard(
              height: 30,
              width: 110,
              pictures: backgroundCategories,
              category: travelCategories,
            ),
            Sections(
              sectionName: "Recommended trips for You",
              trailingText: "View More",
              veritcalMargin: 10,
            ),

            // StreamBuilder for Firestore trips (Horizontal Scroll)
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('trips').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading trips.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final trips = snapshot.data?.docs ?? [];

                if (trips.isEmpty) {
                  return const Center(child: Text('No trips available.'));
                }

                // Make it horizontally scrollable
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                  child: Row(
                    children: trips.map((trip) {
                      final imageUrl = trip['imagePath'] ?? 'https://example.com/default-image.jpg';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailScreen(tripId: trip.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: OneImageCard(
                            location: trip['destination'] ?? 'Unknown destination',
                            imageLink: imageUrl,
                            width: MediaQuery.of(context).size.width * 0.6, // Adjust card width
                            height: 200,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Sections(
              sectionName: "Top Stories",
              trailingText: "",
              veritcalMargin: 10,
            ),
            const Stories1(
              radius: 35,
              margin: .01,
              statusUpdate: Colors.blueAccent,
              horizontalPadding: 6,
            ),
            Sections(
              sectionName: "Popular trips",
              trailingText: "View More",
              veritcalMargin: 10,
            ),
            const StackedImageCard(
              height: 360,
              image1: places,
              image2: places,
              image3: places,
              image4: places,
              location: location,
              year: 2023,
              price: 10000,
              noDays: 3,
              imageUsersBooked1: imageUsersBooked,
              imageUsersBooked2: imageUsersBooked,
              imageUsersBooked3: imageUsersBooked,
              imageUserLiked1: imageUserLiked,
              imageUserLiked2: imageUserLiked,
              imageUserLiked3: imageUserLiked,
              topUserLiked: "Megan",
              noLikes: 500,
              noPeople: 10,
              usersLikedAvatarsSize: 15,
              country: [],
            ),

            // Hot Places Section with Horizontal Scroll
            Sections(
              sectionName: "Hot places",
              trailingText: "View More",
              veritcalMargin: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: Row(
                children: hotPlaces.map((place) {
                  final location = place[1];
                  final imagePath = place[2];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: OneImageCard(
                      location: location,
                      imageLink: imagePath,
                      width: MediaQuery.of(context).size.width * 0.6, // Adjust card width
                      height: 200,
                    ),
                  );
                }).toList(),
              ),
            ),

            Sections(
              sectionName: "Feature experiences",
              trailingText: "View More",
              veritcalMargin: 10,
            ),
            FeaturedExperienceCard(
              height: 260,
              width: 280,
              picture1: featuredExperiences,
              picture2: featuredExperiences,
              picture3: featuredExperiences,
              activity: featuredExperiences,
              location: featuredExperiences,
              country: featuredExperiences,
            ),
          ],
        ),
      ),
    );
  }
}
