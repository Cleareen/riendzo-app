import 'package:flutter/material.dart';
import 'package:riendzo/views/feed/feed.dart';
import 'package:riendzo/views/home/home.dart';
import 'package:riendzo/views/profile/profile.dart';
import 'package:riendzo/views/trips/trips.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // Track the selected tab index
  final ValueNotifier<bool> _isBottomNavVisible = ValueNotifier(true); // Control bottom nav visibility

  // List of screens for each tab
  final List<Widget> _screens = [
    const Home(),
    FeedScreen(),
    const TripsFeed(),
    const Profile(),
  ];

  // Function to handle tab selection
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      // Hide BottomNavigationBar on Profile
      _isBottomNavVisible.value = index != 3;
    });
  }

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollUpdateNotification) {
              if (scrollInfo.scrollDelta != null) {
                // Hide or show BottomNavigationBar based on scroll direction
                if (scrollInfo.scrollDelta! > 0 && _currentIndex != 3) {
                  _isBottomNavVisible.value = false;
                } else if (scrollInfo.scrollDelta! < 0 && _currentIndex != 3) {
                  _isBottomNavVisible.value = true;
                }
              }
            }
            return true;
          },
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),

            ],
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: _isBottomNavVisible,
          builder: (context, isVisible, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300), // Smooth transition
              height: isVisible ? kBottomNavigationBarHeight : 0, // Hide/Show based on visibility
              child: Wrap(
                children: [
               BottomNavigationBar(
                currentIndex: _currentIndex, // Highlight the current selected tab
                onTap: (index) {
                  _onTabSelected(index);
                  // Reset visibility when switching tabs
                  _isBottomNavVisible.value = index != 3; // Hide for Profile
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Discovery',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore),
                    label: 'Feed',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Trips',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
                selectedItemColor: Colors.white, // Customize selected item color
                unselectedItemColor: Colors.black54, // Customize unselected item color
                backgroundColor: Colors.blue, // Set the BottomNavigationBar background color
                type: BottomNavigationBarType.fixed, // Ensure the background color works
              ),
//
                ]
              )
            );

          },
        )
      );

  }
}
