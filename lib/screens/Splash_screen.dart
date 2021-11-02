import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    firestore: this.widget._firestore,
                    auth: this.widget._auth))));

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 110, 20, 20),
          child: Column(children: [
            AnimatedPhysicalModel(
              shape: BoxShape.circle,
              elevation: 90,
              borderRadius: BorderRadius.circular(90),
              shadowColor: Colors.grey,
              color: Colors.blueAccent,
              duration: Duration(seconds: 5),
              child: CircleAvatar(
                radius: 100,
                backgroundImage:
                    AssetImage('assets/images/wits_logo_transparent.png'),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Welkom to the stack',
              style: TextStyle(
                color: const Color(0xff001b5a),
                fontSize: 40,
              ),
            )
          ]),
        ),
      ),
    );
  }
}
