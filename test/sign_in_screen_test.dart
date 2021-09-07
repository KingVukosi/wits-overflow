import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/startup/wits_overflow_app.dart';

void main() {
  testWidgets(
      "The sign in screen displays the accurate number of widgets, each with accurate corresponding image/text",
      (WidgetTester tester) async {
    //act
    await tester.pumpWidget(WitsOverflowApp());
    final witsLogoFinder = find.byType(Image);
    final appNameFinder = find.text("Wits Overflow");
    final welcomeMessageFinder = find.text(
        "Welcome to Wits Overflow.  The ultimate in high-tech question answering goodness.  Enter for all your knowledge seeking needs.");
    final disclaimerFinder = find.text(
        "Currently we\'re catering exclusively to Wits students (lucky you), so click the button below to sign in with your student gmail account and get started on your journey to unlimited knowledge...");

    //assert
    expect(witsLogoFinder, findsOneWidget);
    expect(witsLogoFinder, findsOneWidget);
    expect(appNameFinder, findsOneWidget);
    expect(welcomeMessageFinder, findsOneWidget);
    expect(disclaimerFinder, findsOneWidget);
  });
}
