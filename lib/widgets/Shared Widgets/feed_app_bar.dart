import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:riendzo/views/inbox/inbox.dart';
import 'package:riendzo/views/profile/profile.dart';

class FeedAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  _FeedAppBarState createState() => _FeedAppBarState();
}

class _FeedAppBarState extends State<FeedAppBar> {
  String? _profilePictureUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserProfilePicture();
  }

  Future<void> _getUserProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      try {
        final snapshot = await userRef.get();
        if (snapshot.exists) {
          final profilePicture = snapshot.child('profilePicture').value as String?;
          setState(() {
            _profilePictureUrl = profilePicture ?? 'lib/assets/images/profile/p2.png';
            _isLoading = false;
          });
        } else {
          setState(() {
            _profilePictureUrl = 'lib/assets/images/profile/p2.png';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _profilePictureUrl = 'lib/assets/images/profile/p2.png';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(242, 243, 250, 1.0),
      elevation: 0, // Keep it light
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 6.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Profile()),
            );
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage: _isLoading
                ? const AssetImage('lib/assets/images/profile/p2.png') as ImageProvider<Object>
                : (_profilePictureUrl != null
                ? CachedNetworkImageProvider(_profilePictureUrl!)
                : const AssetImage('lib/assets/images/profile/p2.png') as ImageProvider<Object>),
          ),
        ),
      ),
      actions: [
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
      ], systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }
}
