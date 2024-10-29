import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riendzo/views/authentication/signIn/sign_in.dart';
import 'package:riendzo/widgets/persistent_navbar.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const MainNavigationScreen(
            );
          } else {
            return const SignInPage();
          }
        },
      ),
    );
  }
}
