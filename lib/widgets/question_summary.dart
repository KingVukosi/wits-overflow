import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';

class QuestionSummary extends StatelessWidget {
  // final Map<String, dynamic> data;
  final String questionId;
  final String title;
  final String authorDisplayName;
  final List tags;
  final List<Map<String, dynamic>> votes;
  final List<Map<String, dynamic>> answers;
  final Timestamp createdAt;

  QuestionSummary({
    required this.questionId,
    required this.title,
    required this.tags,
    required this.votes,
    required this.createdAt,
    required this.answers,
    required this.authorDisplayName,
  });

  bool _hasAcceptedAnswer() {
    bool result = false;
    for (var i = 0; i < this.answers.length; i++) {
      if (this.answers[i]['accepted'] == true) {
        result = true;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget _createBadges() {
      List<Widget> list = <Widget>[];

      for (var i = 0; i < this.tags.length; i++) {
        list.add(Flexible(
          child: Container(
            margin: EdgeInsets.only(right: 5),
            color: Color.fromRGBO(225, 236, 244, 1),
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  this.tags[i],
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(57, 115, 157, 1),
                  ),
                )),
          ),
        ));
      }
      return new Row(children: list);
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      QuestionAndAnswersScreen(this.questionId)));
        },
        child: Center(
          child: Container(
              width: double.infinity,
              height: 115,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      top: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [
                Container(
                  color: this._hasAcceptedAnswer() == true
                      ? Color.fromRGBO(231, 251, 239, 1)
                      : Colors.grey.shade100,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  height: double.infinity,
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${countVotes(this.votes)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          SvgPicture.asset(
                            countVotes(this.votes) < 0
                                ? 'assets/icons/caret_down.svg'
                                : 'assets/icons/caret_up.svg',
                            semanticsLabel: 'Feed button',
                            placeholderBuilder: (context) {
                              return Icon(Icons.error,
                                  color: Colors.deepOrange);
                            },
                            height: 11,
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            this.answers.length.toString(),
                            style: TextStyle(
                              color: this._hasAcceptedAnswer() == true
                                  ? Color.fromRGBO(76, 144, 103, 1)
                                  : Colors.grey.shade100,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          SvgPicture.asset(
                            this._hasAcceptedAnswer() == true
                                ? 'assets/icons/question_answer_correct.svg'
                                : 'assets/icons/answer.svg',
                            semanticsLabel: 'Feed button',
                            placeholderBuilder: (context) {
                              return Icon(Icons.error,
                                  color: Colors.deepOrange);
                            },
                            height: 19,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        height: double.infinity,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(this.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(0, 116, 204, 1),
                                      fontWeight: FontWeight.bold,
                                      //fontWeight: FontWeight.bold
                                    )),
                              ),

                              Divider(color: Colors.white, height: 4),

                              // badges/tags
                              Flexible(child: _createBadges()),

                              Divider(color: Colors.white, height: 5),

                              // datetime
                              Flexible(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: Text(
                                            formatDateTime(DateTime
                                                .fromMillisecondsSinceEpoch(this
                                                    .createdAt
                                                    .millisecondsSinceEpoch)),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .disabledColor)),
                                      ),
                                    ),

                                    // author display name
                                    Flexible(
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        child: Text(
                                          this.authorDisplayName,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ])))
              ])),
        ));
  }
}

class QuestionSummaries extends StatefulWidget {
  late final _firestore;
  late final _auth;
  final Future<List<Map<String, dynamic>>> futureQuestions;

  QuestionSummaries({required this.futureQuestions, firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  _QuestionSummariesState createState() => _QuestionSummariesState();
}

class _QuestionSummariesState extends State<QuestionSummaries> {
  bool _loading = false;

  WitsOverflowData witsOverflowData = WitsOverflowData();

  List<Map<String, dynamic>> questions = [];
  late Map<String, List<Map<String, dynamic>>> questionVotes =
      {}; // holds votes information for each question
  late Map<String, Map<String, dynamic>> questionAuthors =
      {}; // hold question author information for each question
  late Map<String, List<Map<String, dynamic>>> questionAnswers =
      {}; // hold question author information for each question

  List<Widget> questionSummaryWidgets = [];
  // int added = 0;

  void getData() async {
    await this.widget.futureQuestions.then((value) {
      this.questions = value;
    });

    if (this.questions.isEmpty) {
      this.questionSummaryWidgets.add(Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                  ),
                  Text(
                    'No favorites to show',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
          ));
      return;
    }

    for (int i = 0; i < this.questions.length; i++) {
      Map<String, dynamic> question = this.questions[i];
      String questionId = question['id'];
      FutureBuilder futureBuilder = FutureBuilder(
        future: Future.wait([
          this.witsOverflowData.fetchUserInformation(question['authorId']),
          this.witsOverflowData.fetchQuestionVotes(questionId),
          this.witsOverflowData.fetchQuestionAnswers(questionId)
        ]),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> author =
                (snapshot.data?[0] as Map<String, dynamic>);

            List<Map<String, dynamic>> questionVotes =
                snapshot.data?[1] as List<Map<String, dynamic>>;

            List<Map<String, dynamic>> questionAnswers =
                snapshot.data?[2] as List<Map<String, dynamic>>;
            QuestionSummary questionSummary = new QuestionSummary(
              answers: questionAnswers,
              questionId: question['id'],
              title: question['title'],
              votes: questionVotes,
              createdAt: question['createdAt'],
              tags: question['tags'],
              authorDisplayName: author['displayName'],
            );
            return questionSummary;
          } else if (snapshot.hasError) {
            return Text('Error occurred');
          } else {
            return Container(
                child: Padding(
              padding: EdgeInsets.all(0),
            ));
          }
        },
      );
      this.questionSummaryWidgets.add(futureBuilder);
    }
    if (this.mounted) {
      this.setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    this._loading = false;
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(25),
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
                  itemCount: this.questionSummaryWidgets.length,
                  itemBuilder: (context, index) {
                    return this.questionSummaryWidgets[index];
                  }),
            ),
          )
        ],
      ),
    );

    // return SingleChildScrollView(
    //   child: Container(
    //     padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: this.questionSummaryWidgets,
    //     ),
    //   ),
    // );

    // =========================================================================

    // return SingleChildScrollView(
    //   child: Container(
    //     padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: this.questionSummaryWidgets,
    //     ),
    //   ),
    // );

    // =========================================================================

    // return Scrollbar(
    //   isAlwaysShown: true,
    //   // interactive: true,
    //   child: SingleChildScrollView(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         SingleChildScrollView(
    //           scrollDirection: Axis.horizontal,
    //           child: SizedBox(
    //             width: 800,
    //             child: GridView.builder(
    //                 scrollDirection: Axis.vertical,
    //                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //                     crossAxisCount: 2, childAspectRatio: 7 / 2),
    //                 shrinkWrap: true,
    //                 itemCount: this.questionSummaryWidgets.length,
    //                 itemBuilder: (context, index) {
    //                   return this.questionSummaryWidgets[index];
    //                 }),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}
