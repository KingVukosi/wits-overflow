import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:wits_overflow/screens/sign_in_screen.dart';

void main() {
  final googleSignIn = MockGoogleSignIn();
  final user = MockUser(
    isAnonymous: false,
    uid: 'qwerty@123456',
    email: 'user@students.wits.ac.za',
    displayName: 'Username',
  );
  test("testing whether a user can sign in with a wits account", () async {});

  group("Testing the UI design of the sign-in screen", () {
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: new SignInScreen()));

    testWidgets('Ui sign in', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      //await tester.pump(); this line rebuilds your activity

      final textFinder = find.text('Wits Overflow');

      expect(textFinder, findsWidgets);
    });

    testWidgets('finding the prompt in the sign in screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.text(
              'Welcome to Wits Overflow.  The ultimate in high-tech question answering goodness.  Enter for all your knowledge seeking needs.'),
          findsOneWidget);
    });

    testWidgets('finding the indicator in the sign in screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
          find.text(
              'Currently we\'re catering exclusively to Wits students (lucky you), so click the button below to sign in with your student gmail account and get started on your journey to unlimited knowledge...'),
          findsOneWidget);
    });

    testWidgets('find the wits logo in the sign in',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byKey(ValueKey("Wits_logo")), findsOneWidget);
    });

    testWidgets('find the wits logo in the sign in',
        (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byKey(ValueKey("Wits_logo")), findsOneWidget);
    });
  });
}
