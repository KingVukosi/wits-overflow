import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import '../utils.dart';

/// TESTS
///   * correct number of answers
///   * should display at most 5 questions per page     -   (not yet implemented)
///   most tests are covered in other widget tests, like
///
///     (question information)
///     * displays question title
///     * displays body
///     * displays author's display name
///     * displays editor's display name        -   (not yet implemented)
///     * displays correct aggregate of votes
///     * the upvote button adds (1) to question votes (if user has not yet voted)
///     * the downvote button adds (-1) to question votes (if user has not yet voted)
///
///     (answers)
///     * displays answer's body
///     * display answer's editor display name (if the the author and editor are different users)
///     * displays correct aggregate of votes
///     * upvote button adds (1) to answer votes (if user has not yet voted)
///     * downvote button adds (-1) to answer votes (if user has not yet voted)
///     * edit button redirects to the answer edit form screen
///     * displays every answers comments
///     *
///

void main() {
  group('Test screens', () {
    testWidgets('Test question and answers screen',
        (WidgetTester tester) async {
      // Populate the fake database.
      final firestore = FakeFirebaseFirestore();

      // add question author information to the database
      String questionAuthorDisplayName = 'testFirstName1 testLastName1';
      String questionAuthorEmail = 'testEmail@domain.com';
      Map<String, dynamic> questionAuthor = {
        'displayName': questionAuthorDisplayName,
        'email': questionAuthorEmail,
      };
      await firestore.collection('users').add(questionAuthor).then((value) {
        questionAuthor.addAll({'id': value.id});
      });

      final auth = await loginUser(
        MockUser(
          uid: questionAuthor['id'],
          displayName: questionAuthor['displayName'],
          email: questionAuthor['email'],
          isAnonymous: false,
          isEmailVerified: true,
        ),
      );

      // add course
      String courseName = 'computer science';
      String courseCode = 'coms';
      Map<String, dynamic> course = {
        'name': courseName,
        'code': courseCode,
      };

      await firestore.collection('courses-2').add(course).then((value) {
        course.addAll({'id': value.id});
      });

      // add module
      String moduleName = 'software design';
      String moduleCode = 'coms3009';
      String moduleCourseId = course['id'];

      Map<String, dynamic> module = {
        'name': moduleName,
        'code': moduleCode,
        'courseId': moduleCourseId,
      };
      await firestore.collection('modules').add(module).then((value) {
        module.addAll({'id': value.id});
      });

      // add question information to the database
      String questionTitle = 'test question title 1';
      String questionBody = 'test question body 1';
      List<String> tags = ['tag_1', 'tag_2', 'tag_3'];
      Timestamp createdAt = Timestamp.fromDate(DateTime(2021, 4, 21, 13, 14));

      Map<String, dynamic> question = {
        'title': questionTitle,
        'body': questionBody,
        'authorId': questionAuthor['id'],
        'moduleId': module['id'],
        'courseId': course['id'],
        'createdAt': createdAt,
        'tags': tags,
      };
      await firestore.collection('questions-2').add(question).then((value) {
        question.addAll({'id': value.id});
      });

      // add question votes
      //  * add question votes users
      //  * add question votes

      // right now the code only cares about number of votes
      // not who voted
      // therefore its okay to
      List<Map<String, dynamic>> questionVotes = [
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': 1},
        {'value': -1},
      ];

      for (var i = 0; i < questionVotes.length; i++) {
        await firestore
            .collection('questions-2')
            .doc(question['id'])
            .collection('votes')
            .add(questionVotes[i]);
      }

      // add question answers
      //  * add question answer users
      //  * add question answers
      //  *
      // one answers should be accepted

      List<Map<String, dynamic>> answerAuthors = [
        {
          'displayName': 'answerFirstName1 answerLastName1',
          'email': 'answerEmail1@domain.com',
        },
        {
          'displayName': 'answerFirstName2 answerLastName2',
          'email': 'answerEmail2@domain.com',
        },
        {
          'displayName': 'answerFirstName3 answerLastName3',
          'email': 'answerEmail3@domain.com',
        },
      ];

      for (var i = 0; i < answerAuthors.length; i++) {
        await firestore.collection('users').add(answerAuthors[i]).then((value) {
          answerAuthors[i].addAll({'id': value.id});
        });
      }

      // add answers (with votes) to database
      List<Map<String, dynamic>> answers = [
        {
          'fields': {
            'body': 'test answer body 1',
            'authorId': answerAuthors[1]['id'],
            'answeredAt': Timestamp.fromDate(DateTime(2021, 4, 30, 7, 11)),
            'accepted': false,
          },
          'votes': <Map<String, dynamic>>[
            {'value': 1},
            {'value': 1},
            {'value': 1},
            {'value': 1},
            {'value': -1},
          ],
        },
        {
          'fields': {
            'body': 'test answer body 3',
            'authorId': answerAuthors[1]['id'],
            'answeredAt': Timestamp.fromDate(DateTime(2021, 5, 1, 21, 21)),
            'accepted': false,
          },
          'votes': <Map<String, dynamic>>[
            {'value': 1},
            {'value': 1},
          ],
        },
        {
          'fields': {
            'body': 'test answer body 3',
            'authorId': answerAuthors[2]['id'],
            'answeredAt': Timestamp.fromDate(DateTime(2021, 5, 23, 10, 5)),
            'accepted': false,
          },
          'votes': <Map<String, dynamic>>[
            {'value': 1},
          ],
        }
      ];

      for (var i = 0; i < answers.length; i++) {
        await firestore
            .collection('questions-2')
            .doc(question['id'])
            .collection('answers')
            .add(answers[i]['fields'])
            .then((value) async {
          answers[i]['fields']['id'] = value.id;
          List<Map<String, dynamic>> v = answers[i]['votes'];
          for (int j = 0; j < v.length; j++) {
            await value.collection('votes').add(v[j]);
          }
        });
      }

      Widget questionAndAnswersScreen = new QuestionAndAnswersScreen(
        question['id'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: WitsOverflowScaffold(
                body: questionAndAnswersScreen,
                firestore: firestore,
                auth: auth,
              ),
            ),
          ));

      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 5));

      // test question basics
      // expect(find.textContaining(question['body']), findsOneWidget);
    });
  });
}
