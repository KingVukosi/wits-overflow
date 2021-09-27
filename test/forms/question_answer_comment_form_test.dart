import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/forms/question_answer_comment_form.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import '../utils.dart';

void main() {
  group("Test question answer comment form", () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> question;
    late Map<String, dynamic> answer;
    // late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    // late Map<String, Map<String, dynamic>> commentsAuthors;
    // late List<Map<String, dynamic>> votes;
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
        'photoURL': ''
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
    });

    testWidgets('displays question title, body, answer body',
        (WidgetTester widgetTester) async {
      QuestionAnswerCommentForm questionAnswerCommentForm =
          QuestionAnswerCommentForm(
        questionId: question['id'],
        answerId: answer['id'],
        firestore: firestore,
        auth: auth,
      );

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: WitsOverflowScaffold(
                body: questionAnswerCommentForm,
                firestore: firestore,
                auth: auth,
              ),
            ),
          ));
      // Widget testWidget = new MediaQuery(
      //     data: new MediaQueryData(),
      //     child: new Directionality(
      //         textDirection: TextDirection.rtl,
      //         child: MaterialApp(
      //           home: Scaffold(
      //               body: questionAnswerCommentForm),
      //         )
      //     )
      // );

      // Widget testWidget = new MediaQuery(
      //     data: new MediaQueryData(),
      //     child: new Directionality(
      //       textDirection: TextDirection.rtl,
      //       child: questionAnswerCommentForm,
      //     ));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump(Duration(seconds: 5));

      expect(find.textContaining(question['title']), findsOneWidget);
      expect(find.textContaining(question['body']), findsOneWidget);

      //
      // expect(findsOneWidget, find.text(answer['body']));
      expect(find.textContaining(answer['body']), findsOneWidget);
    });

    testWidgets('on valid data, add new comment to the answer',
        (WidgetTester widgetTester) async {
      // QuestionAnswerCommentForm questionAnswerCommentForm =\

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: new Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: QuestionAnswerCommentForm(
                  questionId: question['id'],
                  answerId: answer['id'],
                  firestore: firestore,
                  auth: auth,
                ),
              )));

      await widgetTester.pumpWidget(testWidget);
      await widgetTester.pump(Duration(seconds: 5));

      // final textFieldFinder = find.byKey(Key('id_comment_body'));
      final textFieldFinder = find.byType(TextFormField);
      await widgetTester.enterText(
          textFieldFinder, 'test question answer comment 1');

      await widgetTester.tap(find.byKey(Key('id_submit_comment')));

      await widgetTester.pump(Duration(seconds: 7));

      await firestore
          .collection(COLLECTIONS['questions'])
          .doc(question['id'])
          .collection('answers')
          .doc(answer['id'])
          .collection('comments')
          .get()
          .then((value) {
        expect(1, value.docs.length);
        Map<String, dynamic> comment = value.docs.elementAt(0).data();
        expect('test question answer comment 1', comment['body']);
        expect(auth.currentUser?.uid, comment['authorId']);
      });
    });
  });
}
