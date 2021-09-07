import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

import 'utils.dart';

void main() {
  group('Test WitsOverflowData', () {
    // test('get current user should return signed in user', () async {
    //   final googleSignIn = MockGoogleSignIn();
    //   final signinAccount = await googleSignIn.signIn();
    //   final googleAuth = await signinAccount?.authentication;
    //   GoogleAuthProvider.credential(
    //     accessToken: googleAuth?.accessToken,
    //     idToken: googleAuth?.idToken,
    //   );
    //
    //   // Sign in.
    //   final mockUser = MockUser(
    //     isAnonymous: false,
    //     uid: 'uid1',
    //     email: 'testEmail!@domain.com',
    //     displayName: 'testFirstName1 testLastName1',
    //   );
    //   final auth = MockFirebaseAuth(mockUser: mockUser);
    //   // final result = await auth.signInWithCredential(credential);
    //
    //   final firestore = FakeFirebaseFirestore();
    //   WitsOverflowData witsOverflowData = WitsOverflowData();
    //   witsOverflowData.initialize(firestore:firestore, auth:auth);
    //   User? user = witsOverflowData.getCurrentUser();
    //   print('[user?.displayName : ${user?.displayName}]');
    //
    //   expect(user?.displayName, 'testFirstName1 testLastName1');
    //   expect(user?.uid, 'uid1');
    //   expect(user?.email, 'testEmail!@domain.com');
    // });

    test('fetch question method returns valid question', () async {
      final firestore = FakeFirebaseFirestore();
      // create author user
      Map<String, dynamic> author = {
        'displayName': 'testFirstName1 testLastName!',
        'email': 'testEmail1@domain.com',
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
        isEmailVerified: true,
        isAnonymous: false,
      ));

      Map<String, dynamic> question = {
        'title': 'test question title 1',
        'body': 'test question body 1',
        'authorId': author['id'],
        'tags': <String>[
          'testTag1',
          'testTag2',
          'testTag3',
        ],
        'createdAt': Timestamp.fromDate(DateTime(2021, 2, 12, 4, 23)),
      };
      await firestore
          .collection(COLLECTIONS['questions'])
          .add(question)
          .then((value) {
        question.addAll({'id': value.id});
      });

      WitsOverflowData witsOverflowData = WitsOverflowData();
      witsOverflowData.initialize(firestore: firestore, auth: auth);

      Map<String, dynamic>? fQuestion =
          await witsOverflowData.fetchQuestion(question['id']);

      expect(question['title'], fQuestion?['title']);
      expect(question['body'], fQuestion?['body']);
      expect(question['authorId'], fQuestion?['authorId']);
    });
  });
}
