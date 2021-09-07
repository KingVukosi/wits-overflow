import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

// ignore: must_be_immutable
class RecentActivityTab extends StatefulWidget {
  late var _firestore;

  RecentActivityTab({firestore}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
  }

  @override
  _RecentActivityTabState createState() =>
      _RecentActivityTabState(firestore: this._firestore);
}

class _RecentActivityTabState extends State<RecentActivityTab> {
  late bool _loading;

  late List<Map<String, dynamic>> questions;
  late Map<String, List<Map<String, dynamic>>> questionVotes =
      {}; // holds votes information for each question
  late Map<String, Map<String, dynamic>> questionAuthors =
      {}; // hold question author information for each question
  late Map<String, List<Map<String, dynamic>>> questionAnswers =
      {}; // hold question author information for each question

  late var _firestore;
  WitsOverflowData witsOverflowData = new WitsOverflowData();

  @override
  void initState() {
    super.initState();
    this._loading = true;
    this.getData();
  }

  _RecentActivityTabState({firestore}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    witsOverflowData.initialize(firestore: this._firestore);
  }

  void getData() async {
    this.questions = await witsOverflowData.fetchLatestQuestions(3);
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
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
        itemCount: this.questions.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> question = this.questions[index];
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
