import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riendzo/views/authentication/methods/signOut_method.dart';
import 'package:riendzo/views/feed/Post.dart';
import 'package:riendzo/views/feed/like_button_widget.dart';
import 'package:riendzo/views/home/home.dart';
import 'package:riendzo/views/inbox/inbox.dart';
import 'package:riendzo/views/my_trips/my_trips.dart';
import 'package:riendzo/views/profile/ContactUsScreen.dart';
import 'package:riendzo/views/profile/widgets/profile_card.dart';
import 'package:riendzo/views/profile/widgets/profile_summary.dart';
import '../../widgets/Shared Widgets/user_avatar.dart';
import '../../widgets/persistent_navbar.dart';
import '../../widgets/screen_sections.dart';
import 'LegalInformationScreen.dart';
import 'SupportCenterScreen.dart';
import 'package:timeago/timeago.dart' as timeago;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  String? _profilePictureUrl;
  User? _currentUser;
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown time";
    return timeago.format(timestamp.toDate());
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }


  Future<Map<String, String>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final fullName = snapshot.child('name').value as String? ?? 'N/A';
        final email = snapshot.child('email').value as String? ?? 'N/A';
        final profilePicture = snapshot.child('profilePicture').value as String? ??
            'https://example.com/default-user-pic.jpg';

        _nameController.text = fullName;
        _profilePictureUrl = profilePicture;

        return {
          'fullName': fullName,
          'email': email,
          'profilePicture': profilePicture,
        };
      }
    }
    return {
      'fullName': 'N/A',
      'email': 'N/A',
      'profilePicture': 'https://example.com/default-user-pic.jpg',
    };
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

  Future<Map<String, dynamic>> _getUserData1(String userId) async {
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

  Future<void> _updateName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _nameController.text.isNotEmpty) {
      final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);

      await userRef.update({'name': _nameController.text});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name updated successfully!')),
      );

      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _updateProfilePicture();
    }
  }

  Future<String> _uploadImage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("profilePictures/${DateTime.now().millisecondsSinceEpoch}");
    SettableMetadata metadata = SettableMetadata(
      cacheControl: 'max-age=60',
      contentType: 'image/jpeg',
    );

    try {
      UploadTask uploadTask = ref.putFile(image, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_selectedImage != null) {
      final downloadUrl = await _uploadImage(_selectedImage!);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
        await userRef.update({'profilePicture': downloadUrl});

        setState(() {
          _profilePictureUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    }
  }

  void _showEditNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateName();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileOptions(String profilePictureUrl) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('See Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _showProfilePicture(profilePictureUrl);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Update Profile Picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfilePicture(String profilePictureUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: CachedNetworkImage(
            imageUrl: profilePictureUrl,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            extendBodyBehindAppBar: true,
            body: FutureBuilder<Map<String, dynamic>>(
                future: _getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text(''));
                  }

                  final userData = snapshot.data!;
                  final currentProfilePicture = _profilePictureUrl ?? userData['profilePicture']!;



                  // Use StreamBuilder for posts, as before
                  return StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('posts')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              color: Colors.transparent, // Set the container's color to transparent
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                backgroundColor: Colors.transparent, // Make the background of the indicator transparent
                              ),
                            ),
                          );
                        }


            return FutureBuilder<List<PostModel>>(
              future: _getPostsWithLikes(snapshot.data!.docs),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Container(
                      color: Colors.transparent, // Set the container's color to transparent
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        backgroundColor: Colors.transparent, // Make the background of the indicator transparent
                      ),
                    ),
                  );
                }

                final posts = futureSnapshot.data ?? [];




            return ListView(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 120),

                    Expanded(
                      child: Sections(
                        sectionName: 'Profile',
                        trailingText: '',
                        veritcalMargin: 0,
                      ),
                    ),
                  ],
                ),
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        UserAvatar(
                          size: 40,
                          picture: currentProfilePicture,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showProfileOptions(currentProfilePicture),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(Icons.camera_alt, size: 15, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(userData['fullName']!),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                iconSize: 22,
                                onPressed: _showEditNameDialog,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.message, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Inbox()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.black),
                          onPressed: () {
                            // Action for notifications icon
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(userData['email']!),
                  ),
                ),
                const ProfileSummary(),

                // Row containing both General and Support sections
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: ExpansionTile(
                        title: const Text("General"),
                        children: [
                          const ProfileCard(
                            leadingIcon: Icon(Icons.notifications_none),
                            textTitle: 'Notifications',
                            trailingIcon: Icons.chevron_right_outlined,
                          ),
                          ProfileCard(
                            leadingIcon: const Icon(Icons.drive_eta_outlined),
                            textTitle: 'My Trips',
                            trailingIcon: Icons.chevron_right_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MyTrips()),
                              );
                            },
                          ),
                          ProfileCard(
                            leadingIcon: const Icon(Icons.account_balance_wallet),
                            textTitle: 'Wallet',
                            trailingIcon: Icons.chevron_right_outlined,
                            onTap: () {
                              // Implement Wallet Screen Navigation
                            },
                          ),
                          ProfileCard(
                            leadingIcon: const Icon(Icons.people_outline),
                            textTitle: 'Travelers',
                            trailingIcon: Icons.chevron_right_outlined,
                            onTap: () {
                              // Implement Travelers Screen Navigation
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: ExpansionTile(
                        title: const Text("Support"),
                        children: [
                          ProfileCard(
                            leadingIcon: const Icon(Icons.info_outline),
                            textTitle: 'Legal Information',
                            trailingIcon: Icons.chevron_right_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LegalInformationScreen()),
                              );
                            },
                          ),
                          ProfileCard(
                            leadingIcon: const Icon(Icons.help_outline),
                            textTitle: 'Help Center',
                            trailingIcon: Icons.chevron_right_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SupportCenterScreen()),
                              );
                            },
                          ),
                          ProfileCard(
                            leadingIcon: const Icon(Icons.contact_support_outlined),
                            textTitle: 'Contact Us',
                            trailingIcon: Icons.chevron_right_outlined,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>  ContactUsScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                ProfileCard(
                  leadingIcon: const Icon(Icons.logout),
                  textTitle: 'Logout',
                  trailingIcon: Icons.chevron_right_outlined,
                  onTap: signOut,
                ),
                ...posts.map((post) => _buildPostItem(post)).toList(),
              ],
            );
          },
        );
          }
          );

        }),
      ),
    );

  }
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
  Widget _buildPostItem(PostModel post) {

    final screenWidth = MediaQuery.of(context).size.width;
    Color color = Color(0xFFE3E7f1);
    return Card(
      color: color,
      child: Container(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getUserData1(post.userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            return Text("Error loading user data");
                          }

                          final userData = snapshot.data!;
                          final fullName = userData['fullName']!;
                          final profilePicture = userData['profilePicture']!;
                          final isDefaultImage = userData['isDefaultImage'] as bool;

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: isDefaultImage
                                    ? AssetImage('lib/assets/images/profile/p2.png') as ImageProvider
                                    : NetworkImage(profilePicture),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(_formatTimestamp(post.timestamp), style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  Text(post.content, textAlign: TextAlign.justify),
                ],
              ),
            ),

            // Media (image/video) is placed outside of the Padding widget
            if (post.mediaPaths.isNotEmpty)
              Stack(
                children: [
                  _buildMediaSection(post.mediaPaths), // Display the media

                  // Like and comment buttons positioned at the bottom
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      onTap: () => '',
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
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.comment, color: Colors.blue),
                                                    Text(' 0 comments', style: TextStyle(fontSize: 14, color: Colors.blue)),
                                                  ],
                                                ),
                                              );
                                            }
                                            final commentAndReplyCount = snapshot.data!;
                                            return Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.comment, color: Colors.blue),
                                                  Text(' $commentAndReplyCount comments', style: const TextStyle(fontSize: 14, color: Colors.blue)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

