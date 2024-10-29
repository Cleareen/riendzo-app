import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riendzo/views/authentication/methods/signOut_method.dart';
import 'package:riendzo/views/my_trips/my_trips.dart';
import 'package:riendzo/views/profile/ContactUsScreen.dart';
import 'package:riendzo/views/profile/widgets/profile_card.dart';
import 'package:riendzo/views/profile/widgets/profile_summary.dart';
import '../../widgets/Shared Widgets/user_avatar.dart';
import '../../widgets/screen_sections.dart';
import 'LegalInformationScreen.dart';
import 'SupportCenterScreen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController _nameController = TextEditingController();
  File? _selectedImage;
  String? _profilePictureUrl;

  Future<Map<String, String>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid);
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final fullName = snapshot.child('name').value as String? ?? 'N/A';
        final email = snapshot.child('email').value as String? ?? 'N/A';
        final profilePicture =
            snapshot.child('profilePicture').value as String? ??
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

  Future<void> _updateName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _nameController.text.isNotEmpty) {
      final userRef =
          FirebaseDatabase.instance.ref().child('users').child(user.uid);

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
      await _updateProfilePicture(); // Update the profile picture
    }
  }

  Future<String> _uploadImage(File image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child("profilePictures/${DateTime.now().millisecondsSinceEpoch}");
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
        final userRef =
            FirebaseDatabase.instance.ref().child('users').child(user.uid);
        await userRef.update({'profilePicture': downloadUrl});

        setState(() {
          _profilePictureUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated successfully!')),
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
        body: FutureBuilder<Map<String, String>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text(''));
            }

            final userData = snapshot.data!;
            final currentProfilePicture =
                _profilePictureUrl ?? userData['profilePicture']!;

            return ListView(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Sections(
                      sectionName: 'Profile',
                      trailingText: '',
                      veritcalMargin: 0,
                    ),
                    const SizedBox(
                      height: 5,
                      width: 5,
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
                            onTap: () =>
                                _showProfileOptions(currentProfilePicture),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 15,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(userData['fullName']!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _showEditNameDialog,
                        ),
                      ],
                    ),
                    subtitle: Text(userData['email']!),
                  ),
                ),
                const ProfileSummary(),
                Sections(
                  sectionName: "General",
                  trailingText: "",
                  veritcalMargin: 10,
                ),
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
                      MaterialPageRoute(builder: (context) => const MyTrips()),  // Navigates to the Support Center Screen
                    );
                  },
                ),
                const ProfileCard(
                  leadingIcon: Icon(Icons.wallet_outlined),
                  textTitle: 'Wallet',
                  trailingIcon: Icons.chevron_right_outlined,
                ),
                const ProfileCard(
                  leadingIcon: Icon(Icons.people_outline),
                  textTitle: 'Travelers',
                  trailingIcon: Icons.chevron_right_outlined,
                ),
                Sections(
                  sectionName: "Support",
                  trailingText: "",
                  veritcalMargin: 10,
                ),
                ProfileCard(
                  leadingIcon: const Icon(Icons.headphones_outlined),
                  textTitle: 'Support',
                  trailingIcon: Icons.chevron_right_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SupportCenterScreen()),  // Navigates to the Support Center Screen
                    );
                  },
                ),
                const ProfileCard(
                  leadingIcon: Icon(Icons.info_outline),
                  textTitle: 'About us',
                  trailingIcon: Icons.chevron_right_outlined,
                ),
                ProfileCard(
                  leadingIcon: const Icon(Icons.phone_outlined),
                  textTitle: 'Contact Us',
                  trailingIcon: Icons.chevron_right_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContactUsScreen()),
                    );
                  },
                ),
                ProfileCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LegalInformationScreen()),
                    );
                  },
                  leadingIcon: const Icon(Icons.gavel_outlined),
                  textTitle: 'Legal',
                  trailingIcon: Icons.chevron_right_outlined,
                ),
                Sections(
                  sectionName: "More",
                  trailingText: "",
                  veritcalMargin: 10,
                ),
                GestureDetector(
                  onTap: () => showLogoutConfirmationDialog(context), // Pass the current context
                  child: const ProfileCard(
                    leadingIcon: Icon(Icons.logout_outlined),
                    textTitle: 'Logout',
                    trailingIcon: Icons.chevron_right_outlined,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
