// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:wits_overflow/utils/functions.dart';
// import 'package:wits_overflow/widgets/widgets.dart';
//
// import '../utils.dart';

void main() {
  /// testing widgets like
  ///   * UserCase
  group('Test UserCard widget', () {
    // late final firestore;
    // late final auth;
    // late Map<String, dynamic> author;
    // late Map<String, dynamic> editor;
    //
    // int users = 0;
    //
    // Map<String, dynamic> createUserInfo() {
    //   Map<String, dynamic> info =  {
    //     'uid': 'testUid$users',
    //     'displayName': 'testFirstName$users testLastName$users',
    //     'email': 'testEmail$users@domain.com',
    //     'isAnonymous': false,
    //     'isEmailVerified': true,
    //   };
    //   users += 1;
    //   return info;
    // }
    //
    // setUp(() {
    //   firestore = FakeFirebaseFirestore();
    //   author = createUserInfo();
    //
    //   auth = loginUser(MockUser(
    //     uid: author['uid'],
    //     displayName: author['displayName'],
    //     email: author['email'],
    //     isAnonymous: false,
    //     isEmailVerified: true,
    //   ));
    // });
    //
    // /// display author's display name and editor's display name together with
    // /// post datetime and edited datetime
    // /// (when the author and editor are different users )
    // testWidgets('displays displayName and datetime', (WidgetTester tester) async {
    //   editor = createUserInfo();
    //   // Timestamp createdAt = Timestamp.fromDate(DateTime(2021, 4, 23, 11, 15));
    //   // Timestamp editedAt = Timestamp.fromDate(DateTime(2021, 4, 24, 12, 30));
    //   // UserCard userCard = UserCard(
    //   //   createdAt: createdAt,
    //   //   authorId: author['uid'],
    //   //   authorDisplayName: author['displayName'],
    //   // );
    // });
  });

  group('Test Notification widget', () {
    // late final firestore;
    // late final auth;
    // late Map<String, dynamic> user;
    // int users = 0;
    //
    // Map<String, dynamic> createUserInfo() {
    //   Map<String, dynamic> info =  {
    //     'uid': 'testUid$users',
    //     'displayName': 'testFirstName$users testLastName$users',
    //     'email': 'testEmail$users@domain.com',
    //     'isAnonymous': false,
    //     'isEmailVerified': true,
    //   };
    //   users += 1;
    //   return info;
    // }
    //
    // setUp(() {
    //   firestore = FakeFirebaseFirestore();
    //   user = createUserInfo();
    //   auth = loginUser(MockUser(
    //     uid: user['uid'],
    //     displayName: user['displayName'],
    //     email: user['email'],
    //     isAnonymous: false,
    //     isEmailVerified: true,
    //   ));
    //
    //
    // });
    //
    // testWidgets('displays message and datetime', (WidgetTester tester) async {
    //   firestore.collection(COLLECTIONS['users']).doc().set({
    //     'email': user['email'],
    //     'displayName': user['displayName'],
    //   });
    //
    //   auth.toString();
    //
    //   String message = 'test notification message';
    //   Timestamp timestamp = Timestamp.fromDate(DateTime(2021, 3, 22, 12));
    //   NotificationWidget notification = NotificationWidget(message: message, timestamp: timestamp);
    //
    //   Widget testWidget = new MediaQuery(
    //       data: new MediaQueryData(),
    //       child: new Directionality(
    //           textDirection: TextDirection.rtl,
    //           child: notification,
    //       )
    //   );
    //
    //   await tester.pumpWidget(testWidget);
    //
    //   // expect(findsOneWidget, find.text(message));
    //
    // });
  });
}
