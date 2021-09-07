// import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';

main() {
  // Mock sign in with Google.

  test('Test firebase auth sign in', () async {
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in.
    final mockUser = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'bob@somedomain.com',
      displayName: 'Bob',
    );
    final auth = MockFirebaseAuth(mockUser: mockUser);
    await auth.signInWithCredential(credential);

    final firestore = FakeFirebaseFirestore();
    WitsOverflowData witsOverflowData = WitsOverflowData();
    witsOverflowData.initialize(firestore: firestore, auth: auth);
    User? user = witsOverflowData.getCurrentUser();

    expect(user?.uid, 'someuid');
  });

  // late MockGoogleSignIn googleSignIn;
  // setUp(() {
  //   googleSignIn = MockGoogleSignIn();
  // });
  //
  // test('should return idToken and accessToken when authenticating', () async {
  //   final signInAccount = await googleSignIn.signIn();
  //   final signInAuthentication = await signInAccount!.authentication;
  //   expect(signInAuthentication, isNotNull);
  //   expect(googleSignIn.currentUser, isNotNull);
  //   expect(signInAuthentication.accessToken, isNotNull);
  //   expect(signInAuthentication.idToken, isNotNull);
  // });
  //
  // test('should return null when google login is cancelled by the user',
  //         () async {
  //       googleSignIn.setIsCancelled(true);
  //       final signInAccount = await googleSignIn.signIn();
  //       expect(signInAccount, isNull);
  //     });
  // test('testing google login twice, once cancelled, once not cancelled at the same test.', () async {
  //   googleSignIn.setIsCancelled(true);
  //   final signInAccount = await googleSignIn.signIn();
  //   expect(signInAccount, isNull);
  //   googleSignIn.setIsCancelled(false);
  //   final signInAccountSecondAttempt = await googleSignIn.signIn();
  //   expect(signInAccountSecondAttempt, isNotNull);
  // });
}
