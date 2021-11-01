import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:wits_overflow/screens/home_screen.dart';

class SplashScreen extends StatelessWidget {
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
        nextScreen: HomeScreen(),
      ),
    );
  }
}
