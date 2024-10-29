import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riendzo/views/profile/widgets/stats_label.dart';

class ProfileSummary extends StatefulWidget {
  const ProfileSummary({super.key});

  @override
  _ProfileSummaryState createState() => _ProfileSummaryState();
}

class _ProfileSummaryState extends State<ProfileSummary> {
  int tripLikes = 0; // Likes from trips created by the user

  @override
  void initState() {
    super.initState();
    _getTripLikes(); // Fetch the total likes from trips created by the user
  }

  Future<void> _getTripLikes() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Fetch the user's trips (created by the logged-in user) and sum the likes
    QuerySnapshot tripsSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('userId', isEqualTo: currentUser.uid) // Filter trips created by the current user
        .get();

    int totalTripLikes = 0;

    // Loop through each trip to get likes
    for (var tripDoc in tripsSnapshot.docs) {
      QuerySnapshot likesSnapshot = await tripDoc.reference.collection('likes').get();
      totalTripLikes += likesSnapshot.size; // Add the count of likes for this trip
    }

    // Update the state with the total likes
    setState(() {
      tripLikes = totalTripLikes; // Set the total likes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Life is short and the world is wide.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileStatsLabel(
                    dataLabel: 'Likes',
                    dataValue: tripLikes.toString(), // Convert tripLikes to String
                  ),
                  const ProfileStatsLabel(dataLabel: 'Followers', dataValue: '580'),
                  const ProfileStatsLabel(dataLabel: 'Following', dataValue: '5'),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
