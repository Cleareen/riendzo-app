//Sign in Method
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_error_msg_snackBar.dart';
import '../widgets/custom_progress_bar.dart';

void signIn(
    {formSignInKey,
    userEmail,
    userPassword,
    rememberPassword,
    context,
  }) async {
  // validate text field content
  if (formSignInKey.currentState!.validate() && rememberPassword) {
    //Show progress bar while signing in

    //Authenticate user with Firebase
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      //remove the circle indicator as soon as logged in
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      errorMessage(
        context: context,
        child: const Text('Invalid credentials'),
      );
    }
  }
}
