import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/screens/Splash_screen.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets("testing the splash screen", (WidgetTester tester) async {
    //final navObserver = MockNavigatorObserver();
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
          home: new SplashScreen(),
        ));

    await tester.pumpWidget(testWidget);

    expect(tester.takeException(), isInstanceOf<FirebaseException>());
  });
}
