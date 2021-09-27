import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/screens/post_question_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import '../utils.dart';

void main() {
  group("Test question post form screen", () {
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

      PostQuestionScreen postQuestionScreen =
          PostQuestionScreen(firestore: firestore, auth: auth);

      Widget testWidget = new MediaQuery(
          data: new MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: MaterialApp(
              home: WitsOverflowScaffold(
                body: postQuestionScreen,
                firestore: firestore,
                auth: auth,
              ),
            ),
          )
      );

      await tester.pumpWidget(testWidget);

      // TODO: remove the following line and add tests
      expect(true, true);
    });
  });
}
