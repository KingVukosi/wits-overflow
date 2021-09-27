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
import 'package:wits_overflow/widgets/question_summary.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// ignore: must_be_immutable
class ModuleQuestionsScreen extends StatefulWidget {
  final String moduleId;
  final _firestore;
  final _auth;

  ModuleQuestionsScreen({Key? key, required this.moduleId, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth,
        super(key: key);

  @override
  _ModuleQuestionsScreenState createState() => _ModuleQuestionsScreenState();
}

class _ModuleQuestionsScreenState extends State<ModuleQuestionsScreen> {
  late bool _loading = true;

  late List<Map<String, dynamic>> questions;
  late Map<String, List<Map<String, dynamic>>> questionVotes =
      {}; // holds votes information for each question
  late Map<String, Map<String, dynamic>> questionAuthors =
      {}; // hold question author information for each question
  late Map<String, List<Map<String, dynamic>>> questionAnswers =
      {}; // hold question author information for each question

  WitsOverflowData witsOverflowData = new WitsOverflowData();

  void getData() async {
    this.questions = await witsOverflowData.fetchModuleQuestions(
        moduleId: this.widget.moduleId);

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
          itemCount: this.questions.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> question = this.questions[index];
            List<Map<String, dynamic>> questionVotes =
                this.questionVotes[question['id']] == null
                    ? []
                    : this.questionVotes[question['id']]!;
            return QuestionSummary(
              title: question['title'],
              questionId: question['id'],
              createdAt: question['createdAt'],
              answers: this.questionAnswers[question['id']]!,
              authorDisplayName: this.questionAuthors[question['id']]
                  ?['displayName'],
              tags: question['tags'],
              votes: questionVotes,
            );
          }),
    );
  }
}
