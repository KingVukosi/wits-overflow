import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/answers.dart';
import 'package:wits_overflow/widgets/comments.dart';
import 'package:wits_overflow/widgets/question.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

import 'utils.dart';

void main() {
  group('Test widgets', () {
    /// widgets to test:
    /// Question
    /// Comments
    ///   Comment
    ///   Comments
    ///   AnswerComment
    ///   AnswerComments
    ///   QuestionComments
    ///   QuestionComment
    /// Answer
    ///   Answers
    ///   Answer
    /// Meta
    ///   QuestionMeta -
    ///   AnswerMeta
    /// QuestionSummary
    /// Sidebar
    /// UserCard
    ///   QuestionUserCard
    ///   QuestionUserUpdateCard
    ///   AnswerUserCard
    ///   AppBar
    ///
    var firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    /// test the question widget
    testWidgets('Test Question Widget', (WidgetTester tester) async {
      MockUser mockUser = MockUser(
        uid: 'testUserUid1',
        displayName: 'testFirstName1 testLastName1',
        email: 'testEmail@domain.com',
        isAnonymous: false,
        isEmailVerified: true,
      );

      var auth = loginUser(mockUser);

      String title = 'test question title';
      String body = 'test question body';
      int votes = 10;
      String id = 'test question id';
      Timestamp createdAt = Timestamp.now();
      String authorDisplayName = 'test author display name';

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: new QuestionWidget(
              id: id,
              title: title,
              body: body,
              votes: votes,
              authorDisplayName: authorDisplayName,
              createdAt: createdAt,
              firestore: firestore,
              auth: auth,
            ),
          ));

      await tester.pumpWidget(testWidget);

      // Create the Finders.
      final titleFinder = find.text('Test Question Title');
      final bodyFinder = find.text(body);
      final votesFinder = find.text(votes.toString());
      final authorDisplayNameFinder = find.text(authorDisplayName);

      expect(titleFinder, findsOneWidget);
      expect(bodyFinder, findsOneWidget);
      expect(votesFinder, findsOneWidget);
      expect(authorDisplayNameFinder, findsOneWidget);
    });

    /// test the answer widget
    testWidgets('Test Answer Widget', (WidgetTester tester) async {
      MockUser mockUser = MockUser(
        displayName: 'testFirstName1 testLastName1',
        uid: 'testUid1',
        email: 'testEmail1@domain.com',
        isEmailVerified: true,
        isAnonymous: false,
      );

      var auth = loginUser(mockUser);

      // answer user information
      String answerAuthorDisplayName = 'test_first_name_1 test_last_name_1';
      String answerAuthorId = 'test_author_id_1';

      // question information
      String questionId = 'test_question_id_1';

      // answer information
      final String answerId = 'test_answer_body_1';
      final String answerBody = 'test answer body 1';
      final Timestamp answeredAt =
          Timestamp.fromDate(DateTime(2021, 4, 25, 10, 45));
      final bool answerAccepted = true;
      final List<Map<String, dynamic>> answerVotes = [
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': -1},
      ];

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: new Answer(
                votes: answerVotes,
                id: answerId,
                body: answerBody,
                questionId: questionId,
                questionAuthorId: answerAuthorId,
                accepted: answerAccepted,
                authorId: answerAuthorId,
                authorDisplayName: answerAuthorDisplayName,
                answeredAt: answeredAt,
                firestore: firestore,
                auth: auth,
              )));

      await tester.pumpWidget(testWidget);

      // Create the Finders.
      final titleFinder = find.text(answerAuthorDisplayName);
      final messageFinder = find.text(answerBody);

      expect(titleFinder, findsOneWidget);
      expect(messageFinder, findsOneWidget);
    });

    /// test the comment widget
    testWidgets('Test Comment Widget', (WidgetTester tester) async {
      final String body = 'test comment body';
      final Timestamp commentedAt = Timestamp.now();

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: Comment(
                body: body,
                commentedAt: commentedAt,
                displayName: 'test display name',
              )));

      await tester.pumpWidget(testWidget);

      // Create the Finders.
      final bodyFinder = find.text(body);
      // final messageFinder = find.text(body);

      expect(bodyFinder, findsOneWidget);
      // expect(messageFinder, findsOneWidget);
    });

    /// test the question summary widget
    ///  TEST:
    ///   * test that relevant information is displayed
    ///   * test that the question title is displayed in title form
    ///   * Date should be displayed in a correct format
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
      String correctTitleFormat = 'Test Question Summary Title';
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

      final titleFinder = find.text(correctTitleFormat);

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

    testWidgets('Test SideBar Widget', (WidgetTester tester) async {
      // data should have these keys:
      //  * tags      (list)
      //  * votes     (int)
      //  * title     (String)
      //  * createdAt (Timestamp)

      List<Map<String, dynamic>> modules = [];

      // course fields
      // * id
      // * name
      // *
      List<Map<String, dynamic>> courses = [
        {'id': 'course_id_1'},
        {},
        {},
      ];

      // SideDrawer sideDrawer = new SideDrawer();
      //
      // // data
      // String title = 'test question summary title';
      // DateTime createdAt = DateTime(2021, 1, 1, 10, 23);
      // List<String> badges = ['One', 'Two', 'Three'];
      //    child: new Directionality(
      //       textDirection: TextDirection.rtl,
      //       child: questionSummary,
      //     )
      // );
      //
      // await tester.pumpWidget(testWidget);
      //
      // final titleFinder = find.text(correctTitleFormat);

      // final createdAtFinder = find.text(correctDataFormat);

      // expect(titleFinder, findsOneWidget);
    });
  });

  /// ----------------------------------------------------------------------------------------------
  /// TEST WitsOverflowData class
  ///   * fetchQuestions
  ///   * fetchUserQuestions
  ///   * fetchModuleQuestions
  ///   * fetchLatestQuestions
  ///   * fetchCourses
  ///   * fetchModules
  ///   * fetchUserFavouriteQuestions
  ///   * addQuestion

  // group('Test WitsOverflowData class', () {
  //   test('Test fetch questions', () {

  //     // add question to the database

  //     wits_overflow_data = WitsOverflowData();
  //     var questions = wits_overflow_data.fetchQuestions();

  //     expect(Counter().value, 0);

  //     // delete questions
  //   });

  //   test('test fetch user questions', () {
  //     final counter = Counter();

  //     counter.increment();

  //     expect(counter.value, 1);
  //   });

  /// testing utils/functions.dart
  ///   * toTitleCase
  ///   * capitaliseChar
  ///   * formatDateTime

  /// test witsOverflow/utils/functions.dart
  group('Testing functions', () {
    ///
    test('Test toTitleCase', () {
      String line = 'test to title case';
      String titleLine = 'Test To Title Case';
      String toTitleCaseResult = toTitleCase(line);

      expect(toTitleCaseResult, titleLine);
    });

    ///
    test('Test formatDateTime', () {
      DateTime datetime = DateTime(2021, 8, 1, 2, 3, 4);

      String formatDatetime = formatDateTime(datetime);

      expect(formatDatetime.contains('21'), true);
      expect(formatDatetime.contains('Aug'), true);
      expect(formatDatetime.contains('1'), true);
    });

    /// if the time is earlier, (like in latest question)
    /// the time display should be like:
    /// '2 hours' ago / '21 min' ago
    ///
    // test('', (){

    // });
  });
}
