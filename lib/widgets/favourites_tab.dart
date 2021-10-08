import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

// ignore: must_be_immutable
class FavouritesTab extends StatefulWidget {
  late var _firestore;
  late var _auth;

  WitsOverflowData witsOverflowData = WitsOverflowData();

  List<Map<String, dynamic>> questions = [];
  late Map<String, List<Map<String, dynamic>>> questionVotes =
      {}; // holds votes information for each question
  late Map<String, Map<String, dynamic>> questionAuthors =
      {}; // hold question author information for each question
  late Map<String, List<Map<String, dynamic>>> questionAnswers =
      {}; // hold question author information for each question

  List<Widget> questionSummaryWidgets = [];
  int added = 0;

  FavouritesTab({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    {}

    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
  }

  @override
  _FavouritesTabState createState() => _FavouritesTabState();
}

class _FavouritesTabState extends State<FavouritesTab> {
  late bool _loading;

  void getData() async {

    this.widget.questions =
        await this.widget.witsOverflowData.fetchUserFavouriteQuestions(
              userId: this.widget.witsOverflowData.getCurrentUser()!.uid,
            );

    for (int i = this.widget.added; i < this.widget.questions.length; i++) {
      Map<String, dynamic> question = this.widget.questions[i];
      String questionId = this.widget.questions[i]['id'];
      List<Map<String, dynamic>>? questionVotes =
          await this.widget.witsOverflowData.fetchQuestionVotes(questionId);
      this
          .widget
          .questionVotes
          .addAll({questionId: questionVotes == null ? [] : questionVotes});

      Map<String, dynamic>? questionAuthor = await this
          .widget
          .witsOverflowData
          .fetchUserInformation(this.widget.questions[i]['authorId']);
      this.widget.questionAuthors.addAll({questionId: questionAuthor!});

      List<Map<String, dynamic>>? questionAnswers =
          await this.widget.witsOverflowData.fetchQuestionAnswers(questionId);
      this
          .widget
          .questionAnswers
          .addAll({questionId: questionAnswers == null ? [] : questionAnswers});
      this.setState(() {
        this.widget.questionSummaryWidgets.add(QuestionSummary(
              title: question['title'],
              questionId: question['id'],
              createdAt: question['createdAt'],
              answers: this.widget.questionAnswers[question['id']]!,
              authorDisplayName: this.widget.questionAuthors[question['id']]
                  ?['displayName'],
              tags: question['tags'],
              votes: this.widget.questionVotes[question['id']] == null
                  ? []
                  : this.widget.questionVotes[question['id']]!,
            ));
        _loading = false;
        this.widget.added += 1;
      });
    }
    this.setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    this._loading = true;

    if (this.widget.questions.length == 0 ||
        this.widget.added < this.widget.questions.length - 1) {
      this.getData();
    } else {
      this.setState(() {
        this._loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(child: CircularProgressIndicator());
    }
    return Scrollbar(
      isAlwaysShown: true,
      // interactive: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 7 / 2),
                    shrinkWrap: true,
                    itemCount: this.widget.questionSummaryWidgets.length,
                    itemBuilder: (context, index) {
                      return this.widget.questionSummaryWidgets[index];
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
