import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riendzo/views/my_trips/trip_details.dart';

import '../../widgets/Shared Widgets/button_with_icon.dart';
import '../../widgets/Shared Widgets/one_image_card.dart';
import '../../widgets/screen_sections.dart';
import 'booking/booking_page.dart';

class MyTrips extends StatelessWidget {
  const MyTrips({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('You are not logged in. Please log in to see your trips.'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            Sections(
              sectionName: 'Your Ongoing Trips',
              trailingText: "View More",
              veritcalMargin: 10,
            ),
            // Fetch and display ongoing trips created by the user
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('trips')
                  .where('userId', isEqualTo: user.uid) // Filter by the current user's UID
                  .where('status', isEqualTo: 'ongoing') // Filter ongoing trips
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading trips.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final trips = snapshot.data?.docs ?? [];

                if (trips.isEmpty) {
                  return const Center(child: Text('No ongoing trips available.'));
                }

                final currentDate = DateTime.now();
                final dateFormat = DateFormat('dd/MM/yyyy');

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                  child: Row(
                    children: trips.map((trip) {
                      final imageUrl = trip['imagePath'] ?? 'https://example.com/default-image.jpg';
                      final endDate = dateFormat.parse(trip['endDate']); // Parse endDate

                      // Check if trip has ended and update the status
                      if (endDate.isBefore(currentDate)) {
                        // Update the trip's status to "completed"
                        FirebaseFirestore.instance
                            .collection('trips')
                            .doc(trip.id)
                            .update({'status': 'completed'});
                      }

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
            const SizedBox(height: 15),
            ButtonWithIcon(
              iconData: Icons.add,
              iconColor: Colors.white,
              cardColor: Colors.blueAccent,
              textColor: Colors.white,
              text: "Create Trip",
              horizontalPadding: 20,
              verticalPadding: 10,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (e) => const BookingPage(),
                  ),
                );
              },
              TextSize: 15,
            ),
            Sections(
              sectionName: 'Past Trips',
              trailingText: "View More",
              veritcalMargin: 10,
            ),
            // Fetch and display past trips created by the user
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('trips') // Make sure this matches your Firestore path
                  .where('userId', isEqualTo: user.uid) // Filter by user ID
                  .where('status', isEqualTo: 'completed') // Filter past trips
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading trips.');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final trips = snapshot.data?.docs ?? [];

                if (trips.isEmpty) {
                  return const Text('No past trips available.');
                }

                return Column(
                  children: trips.map((trip) {
                    final imageUrl = trip['imagePath'] ?? 'https://example.com/default-image.jpg';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15), // Add space between cards
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailScreen(tripId: trip.id),
                            ),
                          );
                        },
                        child: OneImageCard(
                          location: trip['destination'] ?? 'Unknown destination',
                          imageLink: imageUrl,
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 200,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
