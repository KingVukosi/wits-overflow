import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/forms/question_answer_form.dart';
import 'package:wits_overflow/forms/question_comment_form.dart';
import 'package:wits_overflow/screens/post_question_screen.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';

import 'utils.dart';

void main() {
  group('Wits over flow data', () {
    test('Mock fetches correct data', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('test').add({'field_1': 'value_1'});

      QuerySnapshot<Map<String, dynamic>> tests =
          await firestore.collection('test').get();
      expect(tests.docs.length > 0, true);
    });
  });

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
          auth: auth);
      // Widget testWidget = new MediaQuery(
      //     data: new MediaQueryData(),
      //     child: new Directionality(
      //       textDirection: TextDirection.rtl,
      //       child: questionAndAnswersScreen,
      //     )
      // );

      Widget testWidget = questionAndAnswersScreen;

      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 5));

      // test question basics
      expect(find.textContaining(question['body']), findsOneWidget);
    });
  });

  group('Test form pages', () {
    /// test question post form screen
    testWidgets('Test question post form screen', (WidgetTester tester) async {
      // String questionTitle
      // String questionBody

      final firestore = FakeFirebaseFirestore();

      // steps:
      // 1 - create course(s)
      // 2 - create module(s)

      Map<String, dynamic> course = {
        'name': 'computer science',
        'code': 'coms',
      };
      await firestore
          .collection(COLLECTIONS['courses'])
          .add(course)
          .then((value) {
        course.addAll({'id': value.id});
      });

      Map<String, dynamic> module = {
        'code': 'coms3009',
        'courseId': course['id'],
        'name': 'software design',
      };

      await firestore
          .collection(COLLECTIONS['modules'])
          .add(module)
          .then((value) {
        module.addAll({'id': value.id});
      });

      Map<String, dynamic> author = {
        'displayName': 'testFirstName1 testLastName1',
        'email': 'testEmail@domain.con',
      };

      await firestore
          .collection(COLLECTIONS['users'])
          .add(author)
          .then((value) {
        author.addAll({'id': value.id});
      });

      final auth = await loginUser(
        MockUser(
          uid: author['id'],
          displayName: author['displayName'],
          email: author['email'],
          isEmailVerified: true,
          isAnonymous: false,
        ),
      );

      // String questionTitle = 'test question title 1';
      // String questionBody = 'test question body 1';
      // List<String> tags = ['testTag1', 'testTag2', 'testTag3',];
      // Timestamp createAt = Timestamp.fromDate(DateTime(2021, 4, 23, 2, 23));
      // String questionCourse = 'Software Design';
      // String questionModule = 'Computer Science';

      PostQuestionScreen postQuestionScreen =
          PostQuestionScreen(firestore: firestore, auth: auth);

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: postQuestionScreen,
          ));

      await tester.pumpWidget(testWidget);

      // TODO: remove the following line and add tests
      expect(true, true);
    });

    /// test question answer form screen
    testWidgets('Test question answer form screen',
        (WidgetTester tester) async {
      // String questionTitle
      // String questionBody

      final firestore = FakeFirebaseFirestore();

      // steps:
      // 1 - create course(s)
      // 2 - create module(s)
      // 3 - create question author
      // 2 - create question

      Map<String, dynamic> course = {
        'name': 'computer science',
        'code': 'coms',
      };
      await firestore
          .collection(COLLECTIONS['courses'])
          .add(course)
          .then((value) {
        course.addAll({'id': value.id});
      });

      Map<String, dynamic> module = {
        'code': 'coms3009',
        'courseId': course['id'],
        'name': 'software design',
      };

      await firestore
          .collection(COLLECTIONS['modules'])
          .add(module)
          .then((value) {
        module.addAll({'id': value.id});
      });

      Map<String, dynamic> author = {
        'displayName': 'testFirstName1 testLastName1',
        'email': 'testEmail@domain.con',
      };

      await firestore
          .collection(COLLECTIONS['users'])
          .add(author)
          .then((value) {
        author.addAll({'id': value.id});
      });

      final auth = await loginUser(MockUser(
        uid: author['id'],
        email: author['email'],
        displayName: author['displayName'],
        isAnonymous: false,
        isEmailVerified: true,
      ));

      Map<String, dynamic> question = {
        'title': 'test question title 1',
        'body': 'test question body 1',
        'moduleId': module['id'],
        'courseId': course['id'],
        'authorId': author['id'],
        'createdAt': Timestamp.fromDate(DateTime(2021, 4, 23, 2, 23)),
        'tags': <String>[
          'testTag1',
          'testTag2',
          'testTag3',
        ],
      };

      await firestore
          .collection(COLLECTIONS['questions'])
          .add(question)
          .then((value) {
        question.addAll({'id': value.id});
      });

      QuestionAnswerForm questionAnswerForm = QuestionAnswerForm(
        question['id'],
        question['title'],
        question['body'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: questionAnswerForm,
          ));

      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 5));

      // test that the question title is displayed in title format
      expect(find.textContaining('Test Question Title 1'), findsOneWidget);

      // test that the question body is displayed
      expect(find.textContaining('test question body 1'), findsOneWidget);

      // TODO; add more tests
      // String answerBody = 'test answer body 1';
    });

    /// test question comment form screen
    testWidgets('Test question comment form screen',
        (WidgetTester tester) async {
      // String questionTitle
      // String questionBody

      final firestore = FakeFirebaseFirestore();

      // steps:
      // 1 - create course(s)
      // 2 - create module(s)
      // 3 - create question author
      // 2 - create question

      Map<String, dynamic> course = {
        'name': 'computer science',
        'code': 'coms',
      };
      await firestore
          .collection(COLLECTIONS['courses'])
          .add(course)
          .then((value) {
        course.addAll({'id': value.id});
      });

      Map<String, dynamic> module = {
        'code': 'coms3009',
        'courseId': course['id'],
        'name': 'software design',
      };

      await firestore
          .collection(COLLECTIONS['modules'])
          .add(module)
          .then((value) {
        module.addAll({'id': value.id});
      });

      Map<String, dynamic> author = {
        'displayName': 'testFirstName1 testLastName1',
        'email': 'testEmail@domain.con',
      };

      await firestore
          .collection(COLLECTIONS['users'])
          .add(author)
          .then((value) {
        author.addAll({'id': value.id});
      });

      final auth = await loginUser(MockUser(
        uid: author['id'],
        displayName: author['displayName'],
        email: author['email'],
        isAnonymous: false,
        isEmailVerified: true,
      ));

      Map<String, dynamic> question = {
        'title': 'test question title 1',
        'body': 'test question body 1',
        'moduleId': module['id'],
        'courseId': course['id'],
        'authorId': author['id'],
        'createdAt': Timestamp.fromDate(DateTime(2021, 4, 23, 2, 23)),
        'tags': <String>[
          'testTag1',
          'testTag2',
          'testTag3',
        ],
      };

      await firestore
          .collection(COLLECTIONS['questions'])
          .add(question)
          .then((value) {
        question.addAll({'id': value.id});
      });

      QuestionCommentForm questionCommentFormForm = QuestionCommentForm(
        question['id'],
        question['title'],
        question['body'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: questionCommentFormForm,
          ));

      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 5));

      // test that the question title is display in title format
      expect(find.textContaining('Test Question Title 1'), findsOneWidget);

      // test that the question body is displayed
      expect(find.text('test question body 1'), findsOneWidget);

      // TODO: add more tests like to interact with the form
    });
  });
}
