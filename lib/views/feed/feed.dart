import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riendzo/views/feed/Post.dart';
import 'package:riendzo/widgets/Shared%20Widgets/feed_app_bar.dart';
import '../../widgets/Shared Widgets/avatars_row.dart';
import '../../widgets/Shared Widgets/comments_popup.dart';
import '../../widgets/screen_sections.dart';
import 'like_button_widget.dart';
import 'post_creation_screen.dart'; // Import the post creation screen
import 'package:timeago/timeago.dart' as timeago;

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  XFile? _selectedMedia; // To store selected media (image or video)
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser; // To hold the currently authenticated user
  int commentCount = 0;
  int likeCount = 0;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    return timeago.format(timestamp.toDate());
  }

  // Fetch user profile picture and name by user ID from Realtime Database
  // Fetch user profile picture and name by user ID from Realtime Database
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$userId');

    DatabaseEvent event = await userRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      final userData = snapshot.value as Map<dynamic, dynamic>;
      final profilePicture = userData['profilePicture'];
      final fullName = userData['name'] ?? 'Unknown User';

      return {
        'profilePicture':
            profilePicture ?? '', // If null, fallback to empty string
        'fullName': fullName,
        'isDefaultImage': profilePicture == null ||
            profilePicture.isEmpty, // Check if profile picture is missing
      };
    }

    return {
      'profilePicture': '', // No profile picture
      'fullName': 'Unknown User',
      'isDefaultImage': true, // Use default image
    };
  }

  void _openCommentPopup(PostModel post) {
    // Implement your existing comment popup logic here
    showDialog(
      context: context,
      builder: (context) => CommentsPopup(
        contentId: post.postId, // Pass the post ID as contentId
        contentType: 'post', // Specify that the content is a post
      ),
    );
  }

  Future<int> _getTotalCommentCountWithReplies(String postId) async {
    int totalCommentCount = 0;

    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    // Loop through all comments and add the replies count
    for (var commentDoc in commentsSnapshot.docs) {
      totalCommentCount += 1; // Count the comment itself

      // Fetch the number of replies for each comment
      final repliesSnapshot =
          await commentDoc.reference.collection('replies').get();
      totalCommentCount += repliesSnapshot.size; // Add the number of replies
    }

    return totalCommentCount;
  }

  // Pick video from gallery
  Future<void> _pickMedia(ImageSource source) async {
    final pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      // Navigate to PostCreationScreen with the selected video
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostCreationScreen(media: [pickedFile]),
        ),
      );
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Navigate to PostCreationScreen with the selected image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostCreationScreen(media: [pickedFile]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeedAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                color: Colors
                    .transparent, // Set the container's color to transparent
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue), // Set the color of the indicator
                    backgroundColor: Colors
                        .transparent, // Make the background of the indicator transparent
                  ),
                ),
              ),
            );
          }

          // Fetch posts data with like status
          return FutureBuilder<List<PostModel>>(
            future: _getPostsWithLikes(snapshot.data!.docs),
            builder: (context, futureSnapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    color: Colors
                        .transparent, // Set the container's color to transparent
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue), // Set the color of the indicator
                        backgroundColor: Colors
                            .transparent, // Make the background of the indicator transparent
                      ),
                    ),
                  ),
                );
              }

              final posts = futureSnapshot.data ?? [];

              return ListView(
                children: [
                  _buildPostInputSection(),
                  Sections(
                    sectionName: "Moments",
                    trailingText: "",
                    veritcalMargin: 15,
                  ),
                  const Stories(
                    radius: 35,
                    margin: .01,
                    statusUpdate: Colors.blueAccent,
                    horizontalPadding: 6,
                  ),
                  ...posts.map((post) => _buildPostItem(post)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

// Asynchronous function to get posts and check like status
  Future<List<PostModel>> _getPostsWithLikes(
      List<QueryDocumentSnapshot> docs) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return []; // No user logged in, return empty list

    return await Future.wait(docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;

      // Check if the current user has liked the post
      final likeDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(doc.id)
          .collection('likes')
          .doc(currentUser.uid)
          .get();

      final isLiked = likeDoc.exists && likeDoc.data() != null
          ? likeDoc.data()!['liked'] ?? false
          : false;

      return PostModel(
        postId: doc.id,
        content: data['content'] ?? '',
        mediaPaths: List<String>.from(data['mediaUrls'] ?? []),
        userId: data['userId'] ?? '',
        timestamp: data['timestamp'],
        isLiked: isLiked, // Include the like status
        likeCount: data['likeCount'] ?? 0, // Fetch and include like count
      );
    }).toList());
  }

  Widget _buildPostInputSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to PostCreationScreen without media
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostCreationScreen(media: []),
                  ),
                );
              },
              child: TextField(
                enabled: false, // Disable direct text entry
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () => _pickImage(), // Open gallery to select an image
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () => _pickMedia(
                ImageSource.gallery), // Open gallery to select a video
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(PostModel post) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(8.0),
              // Padding around the content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getUserData(post.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return Text("Error loading user data");
                          }

                          final userData = snapshot.data!;
                          final fullName = userData['fullName']!;
                          final profilePicture = userData['profilePicture']!;
                          final isDefaultImage =
                              userData['isDefaultImage'] as bool;

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: isDefaultImage
                                    ? AssetImage(
                                            'lib/assets/images/profile/p2.png')
                                        as ImageProvider
                                    : NetworkImage(profilePicture),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fullName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(_formatTimestamp(post.timestamp),
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      Spacer(),
                      if (post.userId == _currentUser?.uid)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deletePost(post);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Post'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                   Text(post.content,
                   textAlign: TextAlign.justify,
                   ),
                ],
              ),
            ),

            // Media (image/video) is placed outside of the Padding widget
            if (post.mediaPaths.isNotEmpty)
              Stack(
                children: [
                  _buildMediaSection(post.mediaPaths), // Display the media

                  // Like and comment buttons positioned at the bottom
                  // Like and comment buttons positioned at the bottom
                  Positioned(
                    bottom: 10, // Adjust the position to place it at the bottom of the picture
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spread the buttons
                          children: [
                            // Like Button
                            Flexible(
                              child: LikeButtonWidget(post: post),
                            ),
                            SizedBox(width: 25),

                            // Comment Button
                            Flexible(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _openCommentPopup(post), // Comment action on tap
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200]!.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 7),
                                        child: FutureBuilder<int>(
                                          future: _getTotalCommentCountWithReplies(post.postId),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center, // Center the content
                                                  children: [
                                                    Icon(Icons.comment, color: Colors.blue),
                                                    Text(' 0 comments',
                                                        style: TextStyle(fontSize: 14, color: Colors.blue)),
                                                  ],
                                                ),
                                              );
                                            }
                                            final commentAndReplyCount = snapshot.data!;
                                            return Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center, // Center the content
                                                children: [
                                                  const Icon(Icons.comment, color: Colors.blue),
                                                  Text(' $commentAndReplyCount comments',
                                                      style: const TextStyle(fontSize: 14, color: Colors.blue)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )

                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(List<String> mediaPaths) {
    final screenWidth = MediaQuery.of(context).size.width;

    // If there's only one media (either image or video)
    if (mediaPaths.length == 1) {
      final media = mediaPaths[0];

      // If it's a video, display a placeholder or video player
      if (media.endsWith('.mp4')) {
        return Center(
          child: Text(
              "Video: ${media.split('/').last}"), // Placeholder for video handling
        );
      }

      // If it's an image, display it
      return Container(
        width: screenWidth,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          image: DecorationImage(
            image: NetworkImage(mediaPaths[0]),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // If there are multiple images/videos, use a grid layout
      return GridView.builder(
        shrinkWrap: true,
        physics:
            NeverScrollableScrollPhysics(), // Prevents GridView from scrolling
        itemCount: mediaPaths.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Display two items per row
          childAspectRatio: 1, // Ensure each item is square
          crossAxisSpacing: 10, // Spacing between grid items
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final media = mediaPaths[index];

          // If it's a video, display a placeholder or video widget

          // If it's an image, display it
          return Image.network(
            media, // The URL of the image
            fit: BoxFit.cover,
            width: screenWidth / 2, // Half the screen width for grid items
            height: screenWidth / 2, // Ensure it is square
          );
        },
      );
    }
  }

  void _deletePost(PostModel post) async {
    // Show confirmation dialog before deletion
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    // If the user confirmed deletion
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(post.postId)
            .delete();
        // Optionally, also delete likes and comments if necessary
        // Handle post deletion confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post deleted successfully.')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post. Please try again.')),
        );
      }
    }
  }
}
