import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/screens/module_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import '../utils.dart';

void main() {
  group('Test question summaries widget', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late List<Map<String, dynamic>> questions;
    // late Map<String, dynamic> answer;
    // late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    // late Map<String, Map<String, dynamic>> commentsAuthors;
    // late List<Map<String, dynamic>> votes;
    late Map<String, dynamic> questionAuthorInfo;
    // late Map<String, dynamic> answerAuthorInfo;
    // late Map<String, dynamic> answerEditorInfo;
    int users = 0;

    Map<String, dynamic> createUserInfo() {
      return {
        'uid': 'testUid$users',
        'displayName': 'testFirstName$users testLastName$users',
        'email': 'testEmail$users@domain.com',
        'isAnonymous': false,
        'isEmailVerified': true,
      };
    }

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      // authenticating a user
      questionAuthorInfo = createUserInfo();

      // add user information to the database
      await firestore
          .collection(COLLECTIONS['users'])
          .doc(questionAuthorInfo['uid'])
          .set({
        'displayName': questionAuthorInfo['displayName'],
        'email': questionAuthorInfo['email'],
      });

      auth = await loginUser(MockUser(
        displayName: questionAuthorInfo['displayName'],
        email: questionAuthorInfo['email'],
        isEmailVerified: questionAuthorInfo['isEmailVerified'],
        uid: questionAuthorInfo['uid'],
        isAnonymous: questionAuthorInfo['isAnonymous'],
      ));

      // User author = auth.currentUser!;

      // adding question to the database
      // 1- first by creating course and module
      // 2 - then finally add the question
      course = {
        'name': 'Computer Science',
        'code': 'COMS',
      };

      await firestore
          .collection(COLLECTIONS['courses'])
          .add(course)
          .then((value) {
        course['id'] = value.id;
      });

      module = {
        'name': 'Software Design Project',
        'code': 'COMS3011',
        'courseId': course['id'],
      };

      await firestore
          .collection(COLLECTIONS['modules'])
          .add(module)
          .then((value) {
        module['id'] = value.id;
      });

      List<Map<String, dynamic>> questionAuthors = [
        createUserInfo(),
        createUserInfo(),
        createUserInfo(),
      ];

      // add question authors to the database
      for (int i = 0; i < questionAuthors.length; i++) {
        await firestore.collection('users').doc(questionAuthors[i]['id']).set({
          'displayName': questionAuthors[i]['displayName'],
          'email': questionAuthors[i]['email'],
        });
      }

      // 2 - add question to the database
      questions = [
        {
          'title': 'test question title 1',
          'body': 'test question body 1',
          'createdAt': DateTime(2021, 3, 21, 10, 19),
          'authorId': questionAuthors[0]['uid'],
          'tags': [
            'testTag1',
            'testTag2',
            'testTag3',
          ],
          'courseId': course['id'],
          'moduleId': module['id'],
        },
        {
          'title': 'test question title 2',
          'body': 'test question body 2',
          'createdAt': DateTime(2021, 4, 22, 11, 20),
          'authorId': questionAuthors[1]['uid'],
          'tags': [
            'testTag4',
            'testTag5',
            'testTag6',
          ],
          'courseId': course['id'],
          'moduleId': module['id'],
        },
        {
          'title': 'test question title 3',
          'body': 'test question body 3',
          'createdAt': DateTime(2021, 5, 23, 12, 21),
          'authorId': questionAuthors[2]['uid'],
          'tags': [
            'testTag7',
            'testTag8',
            'testTag9',
          ],
          'courseId': course['id'],
          'moduleId': module['id'],
        },
      ];

      for (int i = 0; i < questions.length; i++) {
        await firestore
            .collection(COLLECTIONS['questions'])
            .add(questions[i])
            .then((value) {
          questions[i]['id'] = value.id;
        });
      }
    });

    testWidgets('displays module\'s questions as question summary widgets',
        (WidgetTester tester) async {
      ModuleQuestionsScreen moduleQuestionsScreen = ModuleQuestionsScreen(
        moduleId: module['id'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(
            size: Size(50000, 50000),
          ),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: WitsOverflowScaffold(
                  firestore: firestore,
                  auth: auth,
                  body: moduleQuestionsScreen,
                ),
              )));

      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 5));
      await tester.pump();
      await tester.pumpAndSettle();

      // print('[questionSummaries: $questionSummaries]');
      for (int i = 0; i < questions.length; i++) {
        final titleFinder = find.text(questions[i]['title']);

        // final votesFinder = find.textContaining('5'); //.text('votes');

        // List<String> tags = questions[i]['tags'];
        final badgeOneFinder = find.textContaining(questions[i]['tags'][0]);
        final badgeTwoFinder = find.textContaining(questions[i]['tags'][1]);
        final badgeThreeFinder = find.textContaining(questions[i]['tags'][2]);

        // final createdAtFinder = find.text(correctDataFormat);
        expect(titleFinder, findsOneWidget);
        // expect(votesFinder, findsOneWidget);

        expect(badgeOneFinder, findsOneWidget);
        expect(badgeTwoFinder, findsOneWidget);
        expect(badgeThreeFinder, findsOneWidget);

        // expect(createdAtFinder, findsOneWidget);
      }
    });

    // testWidgets('when list of questions is empty', (WidgetTester tester) async{
    //
    //   await firestore.collection(COLLECTIONS['questions']).get().then((fQuestions){
    //     for(int i = 0; i < fQuestions.docs.length; i++){
    //       fQuestions.docs.elementAt(i).reference.delete();
    //     }
    //   });
    //
    //   WitsOverflowData witsOverflowData = WitsOverflowData();
    //   witsOverflowData.initialize(firestore: firestore, auth: auth);
    //
    //   Future<List<Map<String, dynamic>>> futureQuestions = witsOverflowData.fetchQuestions();
    //
    //   QuestionSummaries questionSummaries = QuestionSummaries(
    //     futureQuestions: futureQuestions,
    //     firestore: firestore,
    //     auth: auth,
    //   );
    //
    //   Widget testWidget = new MediaQuery(
    //       data: new MediaQueryData(),
    //       child: new Directionality(
    //           textDirection: TextDirection.rtl,
    //           child: MaterialApp(
    //             home: WitsOverflowScaffold(
    //               firestore: firestore,
    //               auth: auth,
    //               body: questionSummaries,
    //             ),
    //           )
    //       )
    //   );
    //
    //   await tester.pumpWidget(testWidget);
    //   await tester.pump();
    //
    //   for(int i = 0; i < questions.length; i++){
    //
    //     final titleFinder = find.text(questions[i]['title']);
    //
    //     // final votesFinder = find.textContaining('5'); //.text('votes');
    //
    //     // List<String> tags = questions[i]['tags'];
    //     final badgeOneFinder = find.textContaining(questions[i]['tags'][0]);
    //     final badgeTwoFinder = find.textContaining(questions[i]['tags'][1]);
    //     final badgeThreeFinder = find.textContaining(questions[i]['tags'][2]);
    //
    //     // final createdAtFinder = find.text(correctDataFormat);
    //
    //     expect(titleFinder, findsNothing);
    //     // expect(votesFinder, findsOneWidget);
    //
    //     expect(badgeOneFinder, findsNothing);
    //     expect(badgeTwoFinder, findsNothing);
    //     expect(badgeThreeFinder, findsNothing);
    //
    //     // expect(createdAtFinder, findsOneWidget);
    //   }
    // });
  });
}
