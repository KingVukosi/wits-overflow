import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

// ignore: must_be_immutable
class MyPostsTab extends StatefulWidget {
  late final _firestore;
  late final _auth;

  MyPostsTab({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  _MyPostsTabState createState() =>
      _MyPostsTabState(firestore: this._firestore, auth: this._auth);
}

class _MyPostsTabState extends State<MyPostsTab> {
  late bool _loading;
  late List<Map<String, dynamic>> questions;
  late Map<String, List<Map<String, dynamic>>> questionVotes =
      {}; // holds votes information for each question
  late Map<String, Map<String, dynamic>> questionAuthors =
      {}; // hold question author information for each question
  late Map<String, List<Map<String, dynamic>>> questionAnswers =
      {}; // hold question author information for each question

  WitsOverflowData witsOverflowData = WitsOverflowData();
  late final _firestore;
  late final _auth;

  _MyPostsTabState({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    print(
        '[[PRINT this._firestore: ${this._firestore}, this._auth: ${this._auth}]');
    this
        .witsOverflowData
        .initialize(firestore: this._firestore, auth: this._auth);

    this.getData();
  }

  void getData() async {
    this.questions = await witsOverflowData.fetchUserQuestions(
        userId: witsOverflowData.getCurrentUser()!.uid);

    for (int i = 0; i < this.questions.length; i++) {
      String questionId = this.questions[i]['id'];
      List<Map<String, dynamic>>? questionVotes =
          await witsOverflowData.fetchQuestionVotes(questionId);
      this
          .questionVotes
          .addAll({questionId: questionVotes == null ? [] : questionVotes});

      Map<String, dynamic>? questionAuthor =
          await witsOverflowData.fetchUserInformation(questions[i]['authorId']);
      this.questionAuthors.addAll({questionId: questionAuthor!});

      List<Map<String, dynamic>>? questionAnswers =
          await witsOverflowData.fetchQuestionAnswers(questionId);
      this
          .questionAnswers
          .addAll({questionId: questionAnswers == null ? [] : questionAnswers});
    }
    this.setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    this._loading = true;
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
        itemCount: this.questions.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> question = this.questions[index];
          // List<Map<String, dynamic>> questionVotes = this.questionVotes[question['id']] == null ? [] : this.questionVotes[question['id']]!;
          return QuestionSummary(
            title: question['title'],
            questionId: question['id'],
            createdAt: question['createdAt'],
            answers: this.questionAnswers[question['id']]!,
            authorDisplayName: this.questionAuthors[question['id']]
                ?['displayName'],
            tags: question['tags'],
            votes: this.questionVotes[question['id']] == null
                ? []
                : this.questionVotes[question['id']]!,
          );
        });
  }
}
