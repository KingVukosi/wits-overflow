// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:core';
// import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
// import 'package:wits_overflow/widgets/question_summary.dart';
import 'package:wits_overflow/widgets/widgets.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// ignore: must_be_immutable
class NotificationsScreen extends StatefulWidget {
  final _firestore;
  final _auth;

  NotificationsScreen({Key? key, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth,
        super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool _loading = true;

  List<Map<String, dynamic>> notifications = [];

  WitsOverflowData witsOverflowData = new WitsOverflowData();

  // add notification to the notifications list
  // notification should be sorted by datetime in descending order
  void _addNotification(String message, Timestamp timestamp) {
    int i = 0;
    for (; i < this.notifications.length; i++) {
      if (timestamp.millisecondsSinceEpoch >=
          this.notifications[i]['timestamp'].millisecondsSinceEpoch) {
        break;
      }
    }
    if (this.mounted) {
      this.setState(() {
        this
            .notifications
            .insert(i, {'message': message, 'timestamp': timestamp});
      });
    }
  }

  void _addQuestionNotifications(Map<String, dynamic> question) {
    // question comments
    this
        .witsOverflowData
        .fetchQuestionComments(question['id'])
        .then((questionComments) {
      if (questionComments != null) {
        for (int i = 0; i < questionComments.length; i++) {
          String userUid = questionComments[i]['authorId'];
          this.witsOverflowData.fetchUserInformation(userUid).then((userInfo) {
            if (userInfo != null) {
              String message =
                  '${userInfo['displayName']} commented on question ${question['title']}';
              this._addNotification(
                  message, questionComments[i]['commentedAt']);
            }
          });
        }
      }
    });

    this
        .witsOverflowData
        .fetchQuestionVotes(question['id'])
        .then((questionVotes) {
      if (questionVotes != null) {
        for (int i = 0; i < questionVotes.length; i++) {
          String userUid = questionVotes[i]['user'];
          this.witsOverflowData.fetchUserInformation(userUid).then((voterInfo) {
            String vote = questionVotes[i]['value'] == 1
                ? 'up-vote'
                : 'down-vote on question ${question['title']}';
            String userDisplayName =
                voterInfo == null ? '[NULL NULL]' : voterInfo['displayName'];
            String message =
                '$userDisplayName added $vote on question ${question['title']}';
            this._addNotification(message, questionVotes[i]['votedAt']);
          });
        }
      }
    });
    this
        .witsOverflowData
        .fetchQuestionAnswers(question['id'])
        .then((questionAnswers) {
      if (questionAnswers != null) {
        for (int i = 0; i < questionAnswers.length; i++) {
          String answerAuthorUid = questionAnswers[i]['authorId'];
          this
              .witsOverflowData
              .fetchUserInformation(answerAuthorUid)
              .then((answerAuthor) {
            if (answerAuthor != null) {
              String displayName = answerAuthor['displayName'];
              String message =
                  '$displayName added answer to question ${question['title']}';
              this._addNotification(message, questionAnswers[i]['answeredAt']);
            }
          });

          // answer votes

          // answer comments
          this
              .witsOverflowData
              .fetchQuestionAnswerComments(
                  questionId: question['id'],
                  answerId: questionAnswers[i]['id'])
              .then((answerComments) {
            if (answerComments != null) {
              for (int i = 0; i < answerComments.length; i++) {
                String userUid = answerComments[i]['authorId'];
                this
                    .witsOverflowData
                    .fetchUserInformation(userUid)
                    .then((userInfo) {
                  if (userInfo != null) {
                    String message =
                        '${userInfo['displayName']} commented on answer from question ${question['title']}';
                    this._addNotification(
                        message, answerComments[i]['commentedAt']);
                  }
                });
              }
            }
          });
        }
      }
    });
  }

  void getData() async {
    String userUid = this.witsOverflowData.getCurrentUser()!.uid;
    // this.userQuestions = await witsOverflowData.fetchUserQuestions(userId: userUid);
    // this.userFavouriteQuestions = await witsOverflowData.fetchUserFavouriteQuestions(userId: userUid);

    witsOverflowData.fetchUserQuestions(userId: userUid).then((userQuestions) {
      for (int i = 0; i < userQuestions.length; i++) {
        this._addQuestionNotifications(userQuestions[i]);
      }
    });

    witsOverflowData
        .fetchUserFavouriteQuestions(userId: userUid)
        .then((userFavouriteQuestions) {
      for (int i = 0; i < userFavouriteQuestions.length; i++) {
        this._addQuestionNotifications(userFavouriteQuestions[i]);
      }
    });

    this.setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(child: CircularProgressIndicator());
    }
    return WitsOverflowScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: ListView.builder(
          padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
          itemCount: this.notifications.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return NotificationWidget(
                message: this.notifications[index - 1]['message'],
                timestamp: this.notifications[index - 1]['timestamp']);
          }),
    );
  }
}
