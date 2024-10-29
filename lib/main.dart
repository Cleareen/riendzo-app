import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:riendzo/firebase_options.dart';
import 'package:riendzo/settings/themes.dart';
import 'package:riendzo/views/authentication/authentificationPage.dart';
import 'package:riendzo/views/feed/feed.dart';
import 'package:riendzo/views/my_trips/booking/booking_page.dart';
import 'package:riendzo/views/my_trips/my_trips.dart';
import 'package:riendzo/views/trips/trips.dart';
import 'package:riendzo/widgets/userProfileProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(

  );
  runApp(
      ChangeNotifierProvider(
          create: (context) => UserProfileProvider(),
      child: const Riendzo())
  );
}

class Riendzo extends StatelessWidget {
  const Riendzo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.defaultTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AnimatedSplashScreen(
          centered: true,
          duration: 1,
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.white70,
          nextScreen: const AuthPage(),
          splash: null,
        ),
      ),
    );
  }
}
