import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/screens/notifications.dart';
// import 'package:wits_overflow/widgets/comments.dart';
import 'package:wits_overflow/utils/functions.dart';

import '../utils.dart';

void main() {
  group('Test comments widget', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> question;
    late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    late Map<String, Map<String, dynamic>> commentsAuthors;

    setUp(() async {
      firestore = FakeFirebaseFirestore();

      // authenticating a user
      Map<String, dynamic> userInfo = {
        'uid': 'testUid1',
        'displayName': 'testFirstName testLastName',
        'email': 'testEmail@domain.com',
        'isAnonymous': false,
        'isEmailVerified': true,
      };

      auth = await loginUser(MockUser(
        displayName: userInfo['displayName'],
        email: userInfo['email'],
        isEmailVerified: userInfo['isEmailVerified'],
        uid: userInfo['uid'],
        isAnonymous: userInfo['isAnonymous'],
      ));

      User user = auth.currentUser!;

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
        'createdAt': DateTime(2021, 3, 21, 34, 19),
        'authorId': user.uid,
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

      // TODO: comments should be sorted by date
      // add comments to the question
      comments = [
        // 1
        {
          'body': 'test question comment 1',
          'authorId': user.uid,
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 1)),
        },

        // 2
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 2)),
          'body': 'test question comment 2',
          'authorId': user.uid,
        },

        // 3
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 3)),
          'body': 'test question comment 3',
          'authorId': user.uid,
        },

        // 4
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 4)),
          'body': 'test question comment 4',
          'authorId': user.uid,
        },

        // 5
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 5)),
          'body': 'test question comment 5',
          'authorId': user.uid,
        },

        // 6
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 6)),
          'body': 'test question comment 6',
          'authorId': user.uid,
        },

        // 7
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 7)),
          'body': 'test question comment 7',
          'authorId': user.uid,
        },

        // 8
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 8)),
          'body': 'test question comment 8',
          'authorId': user.uid,
        }
      ];

      commentsAuthors = {};
      for (int i = 0; i < comments.length; i++) {
        await firestore
            .collection(COLLECTIONS['questions'])
            .doc(question['id'])
            .collection('comments')
            .add(comments[i])
            .then((value) {
          comments[i]['id'] = value.id;
          commentsAuthors.addAll({
            value.id: userInfo,
          });
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

      // navigate to
      // await widgetTester.tap(find.byKey(Key('id_drawer_navigate_to_home')));
    });
  });
}
