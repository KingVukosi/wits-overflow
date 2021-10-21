import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/screens/notifications_screen.dart';
// import 'package:wits_overflow/widgets/comments.dart';
import 'package:wits_overflow/utils/functions.dart';

import '../utils.dart';

void main() {
  group('Test notifications screen', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> question;
    late Map<String, dynamic> answer;
    // late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    // late Map<String, Map<String, dynamic>> commentsAuthors;
    // late List<Map<String, dynamic>> questionVotes;
    late List<Map<String, dynamic>> answerVotes;
    late Map<String, dynamic> questionAuthorInfo;
    // late Map<String, dynamic> questionEditorInfo;
    late Map<String, dynamic> answerAuthorInfo;
    late Map<String, dynamic> answerEditorInfo;

    int users = 0;

    Map<String, dynamic> createUserInfo() {
      users += 1;
      return {
        'uid': 'testUid$users',
        'id': 'testUid$users',
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

      // 2 - add question to the database
      question = {
        'title': 'test question title 1',
        'body': 'test question body 1',
        'createdAt': DateTime(2021, 3, 21, 10, 19),
        'authorId': questionAuthorInfo['uid'],
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

      // add question comments
      Map<String, dynamic> commentUser = createUserInfo();
      await firestore
          .collection(COLLECTIONS['users'])
          .doc(commentUser['uid'])
          .set({
        'email': commentUser['email'],
        'displayName': commentUser['displayName'],
      });

      Map<String, dynamic> questionComment = {
        'body': 'test question comment 1',
        'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 4, 12, 13)),
        'authorId': commentUser['uid'],
      };

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('comments')
          .add(questionComment)
          .then((value) {
        questionComment['id'] = value.id;
      });

      // optional (we don't need to add question votes in order to increase the
      // code coverage
      // add question votes

      answerAuthorInfo = createUserInfo();
      answerEditorInfo = createUserInfo();

      // add answer author information to the database
      await firestore
          .collection(COLLECTIONS['users'])
          .doc(answerAuthorInfo['uid'])
          .set({
        'displayName': answerAuthorInfo['displayName'],
        'email': answerAuthorInfo['email'],
        'uid': answerAuthorInfo['uid'],
      });

      // add answer editor information to the database
      await firestore
          .collection(COLLECTIONS['users'])
          .doc(answerEditorInfo['uid'])
          .set({
        'displayName': answerEditorInfo['displayName'],
        'email': answerEditorInfo['email'],
        'uid': answerEditorInfo['uid'],
      });

      // add answer to the database
      answer = {
        'accepted': true,
        'body': 'test question answer 1',
        'authorId': answerAuthorInfo['uid'],
        'answeredAt': Timestamp.fromDate(DateTime(2021, 3, 21, 13, 59)),
      };

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('answers')
          .add(answer)
          .then((value) {
        answer['id'] = value.id;
      });

      // add answer comment
      Map<String, dynamic> answerCommentAuthor = createUserInfo();
      await firestore
          .collection(COLLECTIONS['users'])
          .doc(answerCommentAuthor['uid'])
          .set({
        'displayName': answerCommentAuthor['displayName'],
        'email': answerCommentAuthor['email'],
      });

      Map<String, dynamic> answerComment = {
        'body': 'test question answer comment body 1',
        'authorId': answerCommentAuthor['uid'],
        'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 1, 17, 4)),
      };

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('answers')
          .doc(answer['id'])
          .collection('comments')
          .add(answerComment)
          .then((value) {
        answerComment['id'] = value.id;
      });

      // save information of users will vote on the answer
      List<Map<String, dynamic>> voteUsers = [];
      for (int i = 4; i < 9; i++) {
        Map<String, dynamic> userInfo = createUserInfo();
        await firestore
            .collection(COLLECTIONS['users'])
            .doc(userInfo['uid'])
            .set({
          'email': userInfo['email'],
          'displayName': userInfo['displayName'],
        });
        voteUsers.add(userInfo);
      }

      // add votes to the question
      answerVotes = [
        // 2
        {
          'value': 1,
          'user': voteUsers[0]['uid'],
        },

        // 3
        {
          'value': 1,
          'user': voteUsers[1]['uid'],
        },

        // 4
        {
          'value': 1,
          'user': voteUsers[2]['uid'],
        },

        // 5
        {
          'value': 1,
          'user': voteUsers[3]['uid'],
        },

        // 6
        {
          'value': -1,
          'user': voteUsers[4]['uid'],
        },
      ];

      for (int i = 0; i < answerVotes.length; i++) {
        firestore
            .collection(COLLECTIONS['questions'])
            .doc(question['id'])
            .collection('answers')
            .doc(answer['id'])
            .collection('answerVotes')
            .add(answerVotes[i])
            .then((value) {
          answerVotes[i]['id'] = value.id;
        });
      }
    });

    testWidgets('Show notifications', (WidgetTester widgetTester) async {
      NotificationsScreen notificationsScreen = NotificationsScreen(
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Scaffold(
                  body: notificationsScreen,
                ),
              )));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump();
    });
  });
}
