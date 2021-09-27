import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/forms/question_comment_form.dart';
import 'package:wits_overflow/utils/functions.dart';

import '../utils.dart';

void main() {
  group("Test question comment form screen", () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    late Map<String, dynamic> question;
    late List<Map<String, dynamic>> questionVotes;
    // late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    // late Map<String, Map<String, dynamic>> commentsAuthors;
    late List<Map<String, dynamic>> voteUsers;

    late Map<String, dynamic> userInfo;

    Map<String, dynamic> createUserData(int number) {
      return {
        'uid': 'testUid$number',
        'displayName': 'testFirstName$number testLastName$number',
        'email': 'testEmail$number@domain.com',
        'isAnonymous': false,
        'isEmailVerified': true,
      };
    }

    setUp(() async {
      firestore = FakeFirebaseFirestore();

      // authenticating a user
      userInfo = {
        'uid': 'testUid1',
        'displayName': 'testFirstName testLastName',
        'email': 'testEmail@domain.com',
        'isAnonymous': false,
        'isEmailVerified': true,
      };

      // add user info to the database
      await firestore.collection(COLLECTIONS['users']).add({
        'uid': userInfo['uid'],
        'displayName': userInfo['displayName'],
        'email': userInfo['email'],
      }).then((value) {
        userInfo['id'] = value.id;
      });

      auth = await loginUser(MockUser(
        displayName: userInfo['displayName'],
        email: userInfo['email'],
        isEmailVerified: userInfo['isEmailVerified'],
        uid: userInfo['uid'],
        isAnonymous: userInfo['isAnonymous'],
      ));

      // User user = auth.currentUser!;

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

      // 2 - add question to the database
      question = {
        'title': 'test question title 1',
        'body': 'test question body 1',
        'createdAt': Timestamp.fromDate(DateTime(2021, 3, 21, 2, 19)),
        'authorId': userInfo['uid'],
        'tags': [
          'testTag1',
          'testTag2',
          'testTag3',
        ],
        'courseId': course['id'],
        'moduleId': module['id'],
      };

      await firestore
          .collection(COLLECTIONS['questions'])
          .add(question)
          .then((value) {
        question['id'] = value.id;
      });

      // question votes users
      voteUsers = [];
      for (int i = 2; i < 7; i++) {
        Map<String, dynamic> info = createUserData(i);
        await firestore.collection(COLLECTIONS['users']).add({
          'uid': info['uid'],
          'displayName': info['displayName'],
          'email': info['email'],
        }).then((value) {
          info['id'] = value.id;
          voteUsers.add(info);
        });
      }

      // question votes
      questionVotes = [
        // 1
        {
          'value': 1,
          'user': voteUsers[0]['uid'],
          'votedAt': Timestamp.fromDate(DateTime(2021, 3, 20, 43)),
        },

        // 2
        {
          'value': 1,
          'user': voteUsers[1]['uid'],
          'votedAt': Timestamp.fromDate(DateTime(2021, 3, 20, 40)),
        },

        // 3
        {
          'value': 1,
          'user': voteUsers[2]['uid'],
          'votedAt': Timestamp.fromDate(DateTime(2021, 3, 20, 59)),
        },

        // 4
        {
          'value': 1,
          'user': voteUsers[3]['uid'],
          'votedAt': Timestamp.fromDate(DateTime(2021, 3, 21, 1)),
        },

        // 5
        {
          'value': 1,
          'user': voteUsers[4]['uid'],
          'votedAt': Timestamp.fromDate(DateTime(2021, 3, 21, 11)),
        },

        // 6
        {
          'value': 1,
          'user': voteUsers[4]['uid'],
          'votedAt': Timestamp.fromDate(DateTime(2021, 3, 21, 15)),
        },
      ];

      for (int i = 0; i < questionVotes.length; i++) {
        await firestore
            .collection(COLLECTIONS['questions'])
            .doc(question['id'])
            .collection('votes')
            .add(questionVotes[i])
            .then((value) {
          questionVotes[i]['id'] = value.id;
        });
      }
    });

    testWidgets('displays question title & body',
        (WidgetTester widgetTester) async {
      QuestionCommentForm questionAnswerForm = QuestionCommentForm(
        questionId: question['id'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Scaffold(
                  body: questionAnswerForm,
                ),
              )));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump();

      expect(find.text(question['title']), findsOneWidget);
      expect(find.textContaining(question['body']), findsOneWidget);
    });

    testWidgets('add answer on valid data', (WidgetTester widgetTester) async {
      QuestionCommentForm questionAnswerForm = QuestionCommentForm(
        questionId: question['id'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Scaffold(
                  body: questionAnswerForm,
                ),
              )));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump();

      String answerBody = 'test question answer body';
      await widgetTester.enterText(
          find.byKey(Key('id_edit_comment_body')), answerBody);
      await widgetTester.tap(find.byKey(Key('id_submit')));

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('comments')
          .where('authorId', isEqualTo: userInfo['uid'])
          .get()
          .then((value) {
        expect(value.docs.length, 1);
        Map<String, dynamic> answer = value.docs.elementAt(0).data();
        expect(userInfo['uid'], answer['authorId']);
        expect(answerBody, answer['body']);
      });
    });
  });
}
