import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/Shared Widgets/comments_popup.dart';
import '../../widgets/Shared Widgets/navigate_to_edit_trip.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool isLiked = false;
  int likeCount = 0; // Variable to store the like count
  int commentCount = 0; // Variable to store the comment count
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLikeStatus(); // Fetch initial like status and count
     _getCommentCount(); // Fetch the comment count
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Fetch if the current user has liked the trip
  void _getLikeStatus() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final tripLikeDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .collection('likes')
        .doc(currentUser.uid)
        .get();

    if (tripLikeDoc.exists) {
      setState(() {
        isLiked = tripLikeDoc['liked'] ?? false;
      });
    }

    // Fetch total like count
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .collection('likes')
        .get();

    setState(() {
      likeCount = likesSnapshot.size; // Update like count
    });
  }

  Future<void> _getCommentCount() async {
    final totalCommentCount = await _getTotalCommentCountWithReplies(widget.tripId);

    setState(() {
      commentCount = totalCommentCount; // Set the total count (comments + replies)
    });
  }

// Helper function to get the total number of comments including replies
  Future<int> _getTotalCommentCountWithReplies(String tripId) async {
    int totalCommentCount = 0;

    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('comments')
        .get();

    // Loop through all comments and add the replies count
    for (var commentDoc in commentsSnapshot.docs) {
      totalCommentCount += 1; // Count the comment itself

      // Fetch the number of replies for each comment
      final repliesSnapshot = await commentDoc.reference.collection('replies').get();
      totalCommentCount += repliesSnapshot.size; // Add the number of replies
    }

    return totalCommentCount;
  }

  // Toggle the like status without showing loading
  void _toggleLike() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Optimistically update the UI by toggling the isLiked state and likeCount
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1; // Update like count
    });

    // Perform the Firestore update in the background
    final tripLikeRef = FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .collection('likes')
        .doc(currentUser.uid);

    tripLikeRef.set({
      'liked': isLiked,
      'userId': currentUser.uid,
    }).catchError((error) {
      // If there's an error, revert the like state and like count
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1; // Revert like count
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like status. Please try again.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Increase AppBar height
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0), // 1 inch padding from the top
          child: AppBar(
            title: const Text('Trip Details'),
            centerTitle: true,
            actions: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('trips').doc(widget.tripId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Container(); // Empty container if trip is not found
                  }

                  final trip = snapshot.data!;
                  final isOwner = trip['userId'] == currentUser?.uid;

                  // Show options button if the current user is the owner of the trip
                  if (isOwner) {
                    return PopupMenuButton<String>(
                      onSelected: (String result) {
                        if (result == 'Edit') {
                          _navigateToEditTrip(context, widget.tripId);
                        } else if (result == 'Delete') {
                          _deleteTrip();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'Edit',
                          child: Text('Edit Trip'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Text('Delete Trip'),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('trips').doc(widget.tripId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading trip details.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Trip not found.'));
          }
          String formatDate(String date) {
            try {
              // Parsing the date from 'dd/MM/yyyy' format
              DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
              // Formatting the date to 'MMM d, y' format
              return DateFormat('MMM d, y').format(parsedDate);
            } catch (e) {
              // Return a fallback message if parsing fails
              return 'Invalid date';
            }
          }
          final trip = snapshot.data!;
          final imageUrl = trip['imagePath'] ?? 'https://example.com/default-image.jpg';
          final destination = trip['destination'] ?? 'Unknown destination';
          final startDate = formatDate(trip['startDate'] ?? ''); // Updated
          final endDate = formatDate(trip['endDate'] ?? '');     // Updated
          final budget = trip['budget'] ?? 'No budget specified';
          final tripName = trip['tripName'] ?? 'Unnamed trip';
          final description = trip['description'] ?? 'No description available';
          final interest = trip['interest'] ?? 'No interest specified';
          final tripType = trip['travelType'] ?? '';

          return SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animated image with fade-in effect
                    AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeIn,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 320,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 29.0),

                    // Card for trip details with elevation and shadow
                    Card(
                      elevation: 42,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                tripName,
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            Text(
                              description,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 16.0),

                            _buildDetailRow(context, 'Destination:', destination),
                            const SizedBox(height: 16.0),
                            _buildDetailRow(context, 'Budget:', budget),
                            const SizedBox(height: 16.0),
                            _buildDetailRow(context, 'Interest:', interest),
                            const SizedBox(height: 16.0),
                            _buildDetailRow(context, 'Trip Type:', tripType),
                            const SizedBox(height: 16.0),

                        // Like and Comment Buttons with Like Count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _toggleLike,
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  Text(
                                    '$likeCount likes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),

                                ],
                              ),
                            ),
                            const SizedBox(width: 32.0),

                            FutureBuilder<int>(
                              future: _getTotalCommentCountWithReplies(widget.tripId), // Fetch total count including replies
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return TextButton.icon(
                                    onPressed: () => _navigateToComments(context),
                                    icon: const Icon(Icons.comment, color: Colors.blue),
                                    label: Text(
                                    '0 comments',
                                    style: TextStyle(fontSize: 16, color: Colors.blue),
                                  )
                                  );
                                }

                                final commentAndReplyCount = snapshot.data!; // Total comments + replies

                                    return TextButton.icon(
                                      onPressed: () => _navigateToComments(context),
                                      icon: const Icon(Icons.comment, color: Colors.blue),
                                      label: Text(
                                        '$commentAndReplyCount comments', // Real-time comment + reply count
                                        style: const TextStyle(fontSize: 16, color: Colors.blue),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),



                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  top: 270, // Position above the trip details card
                  left: 16,
                  right: 16,
                  child: FadeInAnimation(
                    delay: 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateCard('Start Date', startDate),
                        const Icon(Icons.arrow_forward, color: Colors.lightBlueAccent, size: 32),
                        _buildDateCard('End Date', endDate),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateCard(String title, String date) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 9.0),
          Text(
            date,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }


  Widget _buildDetailRow(BuildContext context, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _navigateToEditTrip(BuildContext context, String tripId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTripScreen(tripId: tripId),
      ),
    );
  }

  void _navigateToComments(BuildContext context) {
    _showCommentsPopup(context);
  }

  void _showCommentsPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // To allow full-screen height
      builder: (BuildContext context) {

          return FractionallySizedBox(
            heightFactor: 0.8, // 70% of screen height
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20.0), // Apply roundness to top
              ),
              child: CommentsPopup(contentId:widget.tripId, contentType: 'trip',), // Use the CommentsPopup widget
            ),
          );
        },
    );
  }


  Future<void> _deleteTrip() async {
    try {
      await FirebaseFirestore.instance.collection('trips').doc(widget.tripId).delete();
      Navigator.pop(context); // Return to previous screen after deleting
    } catch (e) {
      print("Error deleting trip: $e");
    }
  }
}

class FadeInAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  const FadeInAnimation({super.key, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final tween = Tween(begin: 0.0, end: 1.0);

    return TweenAnimationBuilder(
      tween: tween,
      duration: const Duration(seconds: 2),
      curve: Curves.easeIn,
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: child,
    );
  }
}