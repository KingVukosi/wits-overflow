import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/widgets/question.dart';

import '../utils.dart';

void main() {
  group('Test question widget', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> question;
    late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    late Map<String, Map<String, dynamic>> commentsAuthors;
    late List<Map<String, dynamic>> questionVotes;
    late List<Map<String, dynamic>> voteUsers;
    late Map<String, dynamic> userInfo;

    Map<String, dynamic> createUserData(int number) {
      return {
        'uid': 'testUid$number',
        'displayName': 'testFirstName$number testLastName$number',
        'email': 'testEmail$number@domain.com',
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

      // vote users
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

      // add comments to the question
      comments = [
        // 1
        {
          'body': 'test question comment 1',
          'authorId': userInfo['uid'],
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 1)),
        },

        // 2
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 2)),
          'body': 'test question comment 2',
          'authorId': userInfo['uid'],
        },

        // 3
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 3)),
          'body': 'test question comment 3',
          'authorId': userInfo['uid'],
        },

        // 4
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 4)),
          'body': 'test question comment 4',
          'authorId': userInfo['uid'],
        },

        // 5
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 5)),
          'body': 'test question comment 5',
          'authorId': userInfo['uid'],
        },

        // 6
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 6)),
          'body': 'test question comment 6',
          'authorId': userInfo['uid'],
        },

        // 7
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 7)),
          'body': 'test question comment 7',
          'authorId': userInfo['uid'],
        },

        // 8
        {
          'commentedAt': Timestamp.fromDate(DateTime(2021, 3, 24, 8)),
          'body': 'test question comment 8',
          'authorId': userInfo['uid'],
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

    /// test that the question widget display:
    ///   * displays question title
    ///   * displays question body
    ///   * up and down vote buttons works
    ///   * edit button redirects to question edit form screen  - (functionality not yet implemented)
    ///   * displays author's display name                      -   (covered in UserCard)
    ///   * displays editor's display name                      -   (covered in UserCard)
    ///   * displays question post datetime                     -   (covered in UserCard)
    ///   * displays question edit datetime                     -   (covered in UserCard)
    ///   * displays question comments                          -   (covered in comments_test.dart)
    ///   *
    ///
    testWidgets('display question body and title', (WidgetTester tester) async {
      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: new QuestionWidget(
              authorId: question['authorId'],
              title: question['title'],
              body: question['body'],
              authorDisplayName: userInfo['displayName'],
              createdAt: question['createdAt'],
              votes: 5,
              id: question['id'],
              firestore: firestore,
              auth: auth,
            ),
          ));

      await tester.pumpWidget(testWidget);
      // await tester.pump(Duration(seconds: 5));

      expect(find.text(question['title']), findsOneWidget);
      expect(find.text(question['body']), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text(userInfo['displayName']), findsOneWidget);
    });

    /// test the question widget
    testWidgets('downvote and upvote buttons', (WidgetTester tester) async {
      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Scaffold(
                    body: Center(
                        child: Container(
                            child: ListView(children: <Widget>[
                  QuestionWidget(
                    authorId: question['authorId'],
                    title: question['title'],
                    body: question['body'],
                    authorDisplayName: userInfo['displayName'],
                    createdAt: question['createdAt'],
                    votes: 5,
                    id: question['id'],
                    firestore: firestore,
                    auth: auth,
                  ),
                ])))),
              )));

      await tester.pumpWidget(testWidget);

      // tap upvote button
      await tester
          .tap(find.byKey(Key('id_question_${question['id']}_upvote_btn')));

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('votes')
          .where('user', isEqualTo: userInfo['uid'])
          .get()
          .then((value) {
        expect(1, value.docs.length);
        Map<String, dynamic> voteInfo = value.docs.elementAt(0).data();
        voteInfo['id'] = value.docs.elementAt(0).id;
        expect(userInfo['uid'], voteInfo['user']);
        expect(1, voteInfo['value']);

        value.docs.elementAt(0).reference.delete();
      });

      // tap upvote button
      await tester
          .tap(find.byKey(Key('id_question_${question['id']}_downvote_btn')));

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('votes')
          .where('user', isEqualTo: userInfo['uid'])
          .get()
          .then((value) {
        expect(1, value.docs.length);
        Map<String, dynamic> voteInfo = value.docs.elementAt(0).data();
        voteInfo['id'] = value.docs.elementAt(0).id;
        expect(userInfo['uid'], voteInfo['user']);
        expect(-1, voteInfo['value']);

        value.docs.elementAt(0).reference.delete();
      });
    });
  });
}
