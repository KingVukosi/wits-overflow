import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';

import '../utils.dart';

void main() {
  group('Wits over flow data', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> userInfo;
    late WitsOverflowData witsOverflowData;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      userInfo = {
        'uid': 'testUserUid1',
        'displayName': 'testFirstName testLastName',
        'email': 'testEmail@domain.com',
      };

      await firestore
          .collection(COLLECTIONS['users'])
          .add(userInfo)
          .then((value) {
        userInfo['id'] = value.id;
      });

      MockUser mockUser = MockUser(
        uid: userInfo['uid'],
        displayName: userInfo['displayName'],
        email: userInfo['email'],
        isAnonymous: false,
        isEmailVerified: true,
      );
      auth = await loginUser(mockUser);
      witsOverflowData = WitsOverflowData();
      witsOverflowData.initialize(firestore: firestore, auth: auth);
    });

    test('Mock fetches correct data', () async {
      await firestore.collection('test').add({'field_1': 'value_1'});

      QuerySnapshot<Map<String, dynamic>> tests =
          await firestore.collection('test').get();
      expect(tests.docs.length > 0, true);
    });

    test('fetch user information', () async {
      // add user information to the database
      Map<String, dynamic>? fUserInfo =
          await witsOverflowData.fetchUserInformation(userInfo['id']);
      expect(userInfo['displayName'], fUserInfo?['displayName']);
      expect(userInfo['uid'], fUserInfo?['uid']);
      expect(userInfo['email'], fUserInfo?['email']);
    });
  });
}
