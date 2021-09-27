import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/widgets/answers.dart';
import 'package:wits_overflow/utils/functions.dart';

import '../utils.dart';

void main() {
  /// test individual answer widget
  /// TESTS
  ///   * display information
  ///     - author's display name
  ///     - editor's display name if edit and author are different users
  ///     - date posted
  ///     - date updated
  ///     - number of up_votes/down_votes
  ///     - answer status (whether is correct)
  ///     - comments (these tests are covered in comments_test.dart)
  ///       - comment body
  ///       - comment author
  ///       - comment date
  ///       - add a comment / show more comments button
  ///   * the question author can accept answer
  ///   * the question author can change accepted answer to another
  ///   * only one answer can be accepted
  ///   * only the question author can accept answers
  ///   * user cannot vote more than once
  ///   * when a user change vote, maybe from downvote (-1) voting to upvote (1)
  group('Test answer widget', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> question;
    late Map<String, dynamic> answer;
    // late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    // late Map<String, Map<String, dynamic>> commentsAuthors;
    late List<Map<String, dynamic>> votes;
    late Map<String, dynamic> questionAuthorInfo;
    late Map<String, dynamic> answerAuthorInfo;
    late Map<String, dynamic> answerEditorInfo;

    Map<String, dynamic> createUserInfo(int number) {
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
      questionAuthorInfo = createUserInfo(1);

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

      answerAuthorInfo = createUserInfo(2);
      answerEditorInfo = createUserInfo(3);

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

      // save information of users will vote on the answer
      List<Map<String, dynamic>> voteUsers = [];
      for (int i = 4; i < 9; i++) {
        Map<String, dynamic> userInfo = createUserInfo(i);
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
      votes = [
        // // 1
        // {
        //   'value': 1,
        //   'user': questionAuthorInfo['uid'],
        // },

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

      for (int i = 0; i < votes.length; i++) {
        firestore
            .collection(COLLECTIONS['questions'])
            .doc(question['id'])
            .collection('answers')
            .doc(answer['id'])
            .collection('votes')
            .add(votes[i])
            .then((value) {
          votes[i]['id'] = value.id;
        });
      }
    });

    /// test that the answer widget displays the
    /// 1 - answer's body
    /// 2 - author's display name,
    /// 3 - editor's display name
    /// 4 - date when the answer was added  - [DateTime(2021, 3, 21, 13, 59)] - [Mar 21 '21 at 13:59]
    /// 5 - date when the was last edited
    /// 6 -  number of votes
    /// 7 - if accepted,
    testWidgets('display valid answer information',
        (WidgetTester widgetTester) async {
      Answer answerWidget = Answer(
        id: answer['id'],
        body: answer['body'],
        answeredAt: answer['answeredAt'],
        votes: votes,
        accepted: answer['accepted'] == null ? false : answer['accepted'],
        authorId: answerAuthorInfo['uid'],
        authorDisplayName: answerAuthorInfo['displayName'],
        questionId: question['id'],
        questionAuthorId: questionAuthorInfo['uid'],
        editorDisplayName: answerEditorInfo['displayName'],
        editedAt: Timestamp.fromDate(DateTime(2021, 3, 24, 1, 14)),
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
            textDirection: TextDirection.rtl,
            child: answerWidget,
          ));

      await widgetTester.pumpWidget(testWidget);

      // 1 - answer's body
      expect(find.text(answer['body']), findsOneWidget);

      // 2 - author's display name
      expect(find.text(answerAuthorInfo['displayName']), findsOneWidget);

      // 3 - editor's display name
      expect(find.text(answerEditorInfo['displayName']), findsOneWidget);

      // 4 - createdAt
      expect(find.text('Mar 21 \'21 at 13:59'), findsOneWidget);

      // 5 - editedAt
      expect(find.text('Mar 24 \'21 at 1:14'), findsOneWidget);

      // 6 - aggregate of votes
      expect(find.text('3'), findsOneWidget);

      // TODO: test that the correct answer icon is present in the widget tree
    });

    testWidgets('upvote and downvote buttons',
        (WidgetTester widgetTester) async {
      Answer answerWidget = Answer(
        id: answer['id'],
        body: answer['body'],
        answeredAt: answer['answeredAt'],
        votes: votes,
        accepted: answer['accepted'] == null ? false : answer['accepted'],
        authorId: answerAuthorInfo['uid'],
        authorDisplayName: answerAuthorInfo['displayName'],
        questionId: question['id'],
        questionAuthorId: questionAuthorInfo['uid'],
        editorDisplayName: answerEditorInfo['displayName'],
        editedAt: Timestamp.fromDate(DateTime(2021, 3, 24, 1, 14)),
        firestore: firestore,
        auth: auth,
      );

      // Widget testWidget = new MediaQuery(
      //     data: new MediaQueryData(),
      //     child: new Directionality(
      //       textDirection: TextDirection.rtl,
      //       child: answerWidget,
      //     )
      // );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Scaffold(
                    body: Center(
                        child: Container(
                            child: ListView(children: <Widget>[
                  answerWidget,
                ])))),
              )));

      await widgetTester.pumpWidget(testWidget);

      // tap the down upvote button
      await widgetTester
          .tap(find.byKey(Key('answer_${answer['id']}_upvote_btn')));

      Map<String, dynamic> questionAuthorVote;
      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('answers')
          .doc(answer['id'])
          .collection('votes')
          .where('user', isEqualTo: questionAuthorInfo['uid'])
          .get()
          .then((value) async {
        // questionAuthorVote = value.doc
        expect(1, value.docs.length);
        questionAuthorVote = value.docs.elementAt(0).data();
        expect(1, questionAuthorVote['value']);
        expect(questionAuthorInfo['uid'], questionAuthorVote['user']);

        await value.docs.elementAt(0).reference.delete();
      });

      // tap the downvote button
      await widgetTester
          .tap(find.byKey(Key('answer_${answer['id']}_downvote_btn')));
      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('answers')
          .doc(answer['id'])
          .collection('votes')
          .where('user', isEqualTo: questionAuthorInfo['uid'])
          .get()
          .then((value) async {
        // questionAuthorVote = value.doc
        expect(1, value.docs.length);
        questionAuthorVote = value.docs.elementAt(0).data();
        expect(-1, questionAuthorVote['value']);
        expect(questionAuthorInfo['uid'], questionAuthorVote['user']);

        await value.docs.elementAt(0).reference.delete();
      });
      // TODO: test that the correct answer icon is present in the widget tree
    });
  });

  /// test a collection of answers
  /// widget to be tested - Answers
  /// TESTS
  ///   * paginator - display at most 5 answers
  ///   * show correct number of answers
  ///   * (OTHER TESTS ARE COVERED IN "Test answer widget")
  group('Test answers widget', () {});
}
