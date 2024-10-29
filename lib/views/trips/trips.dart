import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riendzo/views/my_trips/my_trips.dart';
import 'package:riendzo/views/trips/widgets/trip_searchbar.dart';
import 'package:riendzo/widgets/Shared%20Widgets/button_with_icon.dart';
import 'package:riendzo/widgets/Shared%20Widgets/feed_app_bar.dart';

import '../../widgets/Shared Widgets/one_image_card.dart';
import '../../widgets/screen_sections.dart';
import '../my_trips/trip_details.dart';

class TripsFeed extends StatefulWidget {
  const TripsFeed({super.key});

  @override
  State<TripsFeed> createState() => _TripsFeedState();
}

class _TripsFeedState extends State<TripsFeed> {
  DateTimeRange? selectedDateRange;
  final currentDate = DateTime.now();
  final dateFormat = DateFormat('dd/MM/yyyy');
  List<DocumentSnapshot> filteredTrips = []; // Holds the search results
  bool hasSearched = false; // Flag to determine if a search has been made
  String searchInput = ''; // To store the user's search input

  void onSearch(String searchInput) {
    setState(() {
      this.searchInput = searchInput;
    });

    // Split the search input into individual words
    List<String> searchWords = searchInput.toLowerCase().split(RegExp(r'\s*,\s*|\s+'));

    // Fetch trips from Firestore and filter results in code
    FirebaseFirestore.instance
        .collection('trips')
        .where('status', isEqualTo: 'ongoing')
        .get()
        .then((snapshot) {
      final filtered = snapshot.docs.where((doc) {
        String destination = doc['destination'].toLowerCase();

        // Check if any of the search words are found in the destination
        return searchWords.any((word) => destination.contains(word));
      }).toList();

      setState(() {
        filteredTrips = filtered;
        hasSearched = true;
      });
    })
        .catchError((error) {
      print("Error fetching trips: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
        padding: const EdgeInsets.only(top: 20),
     child: ListView(
       children: [
          // Search Card with Date Range Picker
          SearchCard(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (range) {
              setState(() {
                selectedDateRange = range;
              });
            },
            onSearch: onSearch, // Pass the search function here
          ),
          const SizedBox(height: 20), // Space before Create Trip Button

          // "Create Your Own Trip" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: ButtonWithIcon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyTrips()));
              },
              iconData: Icons.add,
              iconColor: Colors.white,
              cardColor: Colors.blueAccent,
              textColor: Colors.white,
              text: "Create Your Own Trip",
              horizontalPadding: 20,
              verticalPadding: 10,
              TextSize: 15,
            ),
          ),
          const SizedBox(height: 20), // Space before Ongoing Trips/Search Results

          // Ongoing Trips Section or Search Results Section
          // Ongoing Trips Section or Search Results Section
          // Ongoing Trips Section or Search Results Section
          Sections(
            sectionName: hasSearched && filteredTrips.isNotEmpty
                ? "Search Results for '$searchInput'" // Custom text when searched and results exist
                : 'Ongoing Trips', // Default section name
            trailingText: hasSearched ? '' : 'View More',
            veritcalMargin: 10,
          ),

      // Conditionally display either the search results or "No results found" message
          hasSearched
              ? filteredTrips.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Text(
                "No results found for '$searchInput'",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
              : displayTrips(filteredTrips) // Display search results
              : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('status', isEqualTo: 'ongoing') // Filter by ongoing trips
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

              return displayTrips(trips);
            },
          ),


          const SizedBox(height: 15),

          // Past Trips Section
          Sections(
            sectionName: 'Past Trips',
            trailingText: "View More",
            veritcalMargin: 10,
          ),
          // StreamBuilder for past trips
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('trips')
                .where('status', isEqualTo: 'completed') // Filter by completed trips
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
                return const Center(child: Text('No past trips available.'));
              }

              return displayTrips(trips);
            },
          ),
        ],
      ),
    )
    );
  }

  // Helper method to display trips
  Widget displayTrips(List<DocumentSnapshot> trips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: trips.map((trip) {
          final imageUrl = trip['imagePath'] ?? 'https://example.com/default-image.jpg';
          final endDate = dateFormat.parse(trip['endDate']);

          // Check if trip has ended and update the status
          if (endDate.isBefore(currentDate)) {
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
                width: MediaQuery.of(context).size.width * 0.5, // Same card width as MyTrips
                height: 200,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
