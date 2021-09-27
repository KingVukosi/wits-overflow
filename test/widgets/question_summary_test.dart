import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

void main() {
  group('Test question summary widget', () {
    /// test the question summary widget
    ///  TEST:
    ///   * test that relevant information is displayed
    ///   * test that the question title is displayed in title form
    ///   * Date should be displayed in a correct format
    ///   * should redirect to question and answer page on onclick
    testWidgets('Test QuestionSummary Widget', (WidgetTester tester) async {
      // data should have these keys:
      //  * tags      (list)
      //  * votes     (int)
      //  * title     (String)
      //  * createdAt (Timestamp)

      // data
      String questionId = 'questionId1';
      String title = 'test question summary title';
      Timestamp createdAt = Timestamp.fromDate(DateTime(2021, 1, 1, 10, 23));
      List<String> tags = ['One', 'Two', 'Three'];
      List<Map<String, dynamic>> votes = [
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': 1},
      ];

      // correct values
      String correctDataFormat = 'Jan 1 \'21 at 10:23';

      Map<String, dynamic> data = {
        'title': title,
        'createdAt': createdAt,
        'tags': tags,
        'votes': votes,
      };

      QuestionSummary questionSummary = QuestionSummary(
        title: title,
        createdAt: createdAt,
        tags: tags,
        votes: votes,
        authorDisplayName: 'testFirstName1 testLastName1',
        questionId: questionId,
        answers: [],
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: questionSummary,
          ));

      await tester.pumpWidget(testWidget);

      final titleFinder = find.text(title);

      final votesFinder = find.textContaining('5'); //.text('votes');

      final badgeOneFinder = find.textContaining(data['tags'][0]);
      final badgeTwoFinder = find.textContaining(data['tags'][1]);
      final badgeThreeFinder = find.textContaining(data['tags'][2]);

      final createdAtFinder = find.text(correctDataFormat);

      expect(titleFinder, findsOneWidget);
      expect(votesFinder, findsOneWidget);

      expect(badgeOneFinder, findsOneWidget);
      expect(badgeTwoFinder, findsOneWidget);
      expect(badgeThreeFinder, findsOneWidget);

      expect(createdAtFinder, findsOneWidget);
    });
  });
}
