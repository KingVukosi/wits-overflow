import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:wits_overflow/forms/answer_edit_form.dart';
import 'package:wits_overflow/forms/question_edit_form.dart';
import 'package:wits_overflow/utils/functions.dart';

import '../utils.dart';

void main() {
  group("Test question post form screen", () {
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

    testWidgets('displays question title & body',
        (WidgetTester widgetTester) async {
      QuestionEditForm questionEditForm = QuestionEditForm(
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
                  body: questionEditForm,
                ),
              )));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump();

      expect(find.text(question['title']), findsOneWidget);
      expect(find.textContaining(question['body']), findsOneWidget);
    });

    testWidgets('update answer information on valid data',
        (WidgetTester widgetTester) async {
      QuestionEditForm questionEditForm = QuestionEditForm(
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
                  body: questionEditForm,
                ),
              )));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump();

      String titleEdit = 'test question title edit 1';
      String bodyEdit = 'test question body edit 1';
      await widgetTester.enterText(find.byKey(Key('id_edit_title')), titleEdit);
      await widgetTester.enterText(find.byKey(Key('id_edit_body')), bodyEdit);

      await widgetTester.tap(find.byKey(Key('id_submit')));

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .get()
          .then((value) {
        // expect(1, value.docs.length);

        // Map<String, dynamic> answer = value.docs.elementAt(0).data();
        expect(value['title'], titleEdit);
        expect(value['body'], bodyEdit);
      });
    });
  });
}
