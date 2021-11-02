import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:wits_overflow/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  // This widget is the root of your application.

  late final _firestore;
  late final _auth;

  SplashScreen({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
          duration: 5000,
          splash: Container(
            child: Column(children: [
              Image.asset(
                'assets/images/wits_logo_transparent.png',
                height: 170,
                key: ValueKey("Splash_wits_logo"),
                width: 200,
                fit: BoxFit.cover,
              ),
              Text(
                "Welcome to the stack",
                key: ValueKey("Splash_text"),
                style: TextStyle(
                  color: const Color(0xff001b5a),
                  fontSize: 26,
                ),
              ),
            ]),
          ),
          animationDuration: Duration(seconds: 4),
          pageTransitionType: PageTransitionType.rightToLeft,
          splashTransition: SplashTransition.fadeTransition,
          nextScreen: HomeScreen(
              firestore: this.widget._firestore, auth: this.widget._auth)),
    );
  }
}
