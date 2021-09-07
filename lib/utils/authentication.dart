import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wits_overflow/screens/home_screen.dart';
//import 'package:wits_overflow/screens/home_screen.dart';
//import 'package:wits_overflow/screens/user_info_screen.dart';
import 'package:wits_overflow/utils/storage.dart';

// import 'package:wits_overflow/screens/api_request_example.dart';
class Authentication {
  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }

    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    // if user is logging from the web
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      authProvider.setCustomParameters({"prompt": 'select_account'});

      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Error occurred using Google Sign-In. Try again.',
          ),
        );
      }

      // if the user is logging from mobile application
    }

    // if user is logging from mobile application
    else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // final GoogleSignInAccount? googleSignInAccount =
      //     await googleSignIn.signIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);

          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential.',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign-In. Try again.',
            ),
          );
        }
      }
    }

    if (user != null) {
      var email = user.email;

      Map<String, String> data = {
        'displayName': user.displayName.toString(),
        'email': user.email.toString(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data);

      if (email != null && !email.endsWith('wits.ac.za')) {
        // Sign out
        user = null; // Important
        await signOut(context: context);

        ScaffoldMessenger.of(context).showSnackBar(
          Authentication.customSnackBar(
            content: 'Only Wits users are permitted at this stage!',
          ),
        );
      } else {
        // //   // Save details to secure storage:
        var token = await user.getIdToken();
        SecureStorage.write('user.email', user.email.toString());
        SecureStorage.write('user.name', user.displayName.toString());
        SecureStorage.write('user.token', token);
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      await FirebaseAuth.instance.signOut();

      // Clean up
      SecureStorage.delete('user.email');
      SecureStorage.delete('user.name');
      SecureStorage.delete('user.token');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),
      );
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}
