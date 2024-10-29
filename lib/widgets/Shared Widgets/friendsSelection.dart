import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../views/my_trips/booking/widgets/custom_button.dart';

class FriendsSelectionPage extends StatefulWidget {
  const FriendsSelectionPage({super.key});

  @override
  _FriendsSelectionPageState createState() => _FriendsSelectionPageState();
}

class _FriendsSelectionPageState extends State<FriendsSelectionPage> {
  // List of hardcoded users
  final List<String> _friends = [
    "John Doe",
    "Jane Smith",
    "Michael Johnson",
    "Emily Davis",
    "William Brown",
    "Jessica Wilson",
    "David Martinez"
  ];

  // To track selected friends
  final Map<String, bool> _selectedFriends = {};

  @override
  void initState() {
    super.initState();
    // Initialize the selectedFriends map with false for each friend
    for (var friend in _friends) {
      _selectedFriends[friend] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _friends.length,
                itemBuilder: (context, index) {
                  String friend = _friends[index];
                  return CheckboxListTile(
                    title: Text(friend),
                    value: _selectedFriends[friend],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedFriends[friend] = value ?? false;
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  horizontalPadding: 30,
                  cardColor: Colors.blueAccent,
                  onPressed: () {
                    // Print or handle selected friends (if needed)
                    print('Selected Friends: ${_selectedFriends.keys.where((friend) => _selectedFriends[friend] == true).toList()}');

                    // Navigate back to the booking page
                    Navigator.pop(context);
                  },
                  text: "Invite",
                  textColor: Colors.white,
                  TextSize: 16.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
