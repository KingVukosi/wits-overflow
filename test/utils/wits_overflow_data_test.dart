import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // test('fetch question', () async {
    //   // add user information to the database
    //   Map<String, dynamic>? fUserInfo =
    //   await witsOverflowData.fetchUserInformation(userInfo['id']);
    //   expect(userInfo['displayName'], fUserInfo?['displayName']);
    //   expect(userInfo['uid'], fUserInfo?['uid']);
    //   expect(userInfo['email'], fUserInfo?['email']);
    // });


    test('fetch questions', () async {
      await witsOverflowData.fetchQuestions();
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

  group('Test Wits Overflow Data Class', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late Map<String, dynamic> question;
    late List<Map<String, dynamic>> comments;
    late Map<String, dynamic> module;
    late Map<String, dynamic> course;
    late Map<String, Map<String, dynamic>> commentsAuthors;
    WitsOverflowData witsOverflowData = WitsOverflowData();

    late Map<String, dynamic> answer;
    // late List<Map<String, dynamic>> comments;
    // late Map<String, Map<String, dynamic>> commentsAuthors;
    late List<Map<String, dynamic>> votes;
    late Map<String, dynamic> questionAuthorInfo;
    late Map<String, dynamic> answerAuthorInfo;
    late Map<String, dynamic> answerEditorInfo;

    int users = 0;
    Map<String, dynamic> createUserInfo() {
      users += 1;
      return {
        'uid': 'testUid$users',
        'displayName': 'testFirstName$users testLastName$users',
        'email': 'testEmail$users@domain.com',
        'isAnonymous': false,
        'isEmailVerified': true,
      };
    }


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

      witsOverflowData.initialize(firestore: firestore, auth: auth);

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

      answerAuthorInfo = createUserInfo();
      answerEditorInfo = createUserInfo();

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
        Map<String, dynamic> userInfo = createUserInfo();
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


    test('fetch question comments', (){
      witsOverflowData.fetchQuestionComments(question['id']);
    });

    test('fetch question comments', (){
      witsOverflowData.fetchQuestionVotes(question['id']);
    });


    test('fetch question answers', (){
      witsOverflowData.fetchQuestionAnswers(question['id']);
    });


    test('fetch module questions', (){
      witsOverflowData.fetchModuleQuestions(moduleId: module['id']);
    });

    test('fetch module questions', (){
      witsOverflowData.fetchQuestionAnswerComments(questionId: question['id'], answerId: answer['id']);
    });








  });
}
