// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:core';
// import 'dart:core';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/forms/answer_quiz_screen.dart';
import 'package:wits_overflow/forms/quiz_create_form.dart';
import 'package:wits_overflow/utils/functions.dart';
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

  late List<Map<String, dynamic>> quizzes = [];
  // tabs
  late QuestionSummaries questionsTab;
  late QuizzesTab quizzesTab;

  late Map<String, dynamic> module;

  WitsOverflowData witsOverflowData = new WitsOverflowData();

  void getData() async {
    await this
        .widget
        ._firestore
        .collection('quizzes')
        .where('moduleId', isEqualTo: this.widget.moduleId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      snapshot.docs.forEach((quiz) {
        Map<String, dynamic> q = quiz.data();
        q.addAll({'id': quiz.id});
        this.quizzes.add(q);
      });
    });

    await this
        .widget
        ._firestore
        .collection(COLLECTIONS['modules'])
        .doc(this.widget.moduleId)
        .get()
        .then((value) {
      Map<String, dynamic>? data = value.data();
      // print('[MODULE -> moduleId: ${this.widget.moduleId} module: $data]');
      this.module = data!;
      this.module.addAll({'id': value.id});
      // this.module = value.data();
    });

    // this.questions = await witsOverflowData.fetchModuleQuestions(
    //     moduleId: this.widget.moduleId);
    //
    // for (int i = 0; i < this.questions.length; i++) {
    //   String questionId = this.questions[i]['id'];
    //   List<Map<String, dynamic>>? questionVotes =
    //       await witsOverflowData.fetchQuestionVotes(questionId);
    //   this
    //       .questionVotes
    //       .addAll({questionId: questionVotes == null ? [] : questionVotes});
    //
    //   Map<String, dynamic>? questionAuthor =
    //       await witsOverflowData.fetchUserInformation(questions[i]['authorId']);
    //   this.questionAuthors.addAll({questionId: questionAuthor!});
    //
    //   List<Map<String, dynamic>>? questionAnswers =
    //       await witsOverflowData.fetchQuestionAnswers(questionId);
    //   this
    //       .questionAnswers
    //       .addAll({questionId: questionAnswers == null ? [] : questionAnswers});
    // }

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

    this.questionsTab = QuestionSummaries(
      futureQuestions: this
          .witsOverflowData
          .fetchModuleQuestions(moduleId: this.widget.moduleId),
      firestore: this.widget._firestore,
      auth: this.widget._auth,
    );

    this.quizzesTab = QuizzesTab(
      moduleId: this.widget.moduleId,
      firestore: this.widget._firestore,
      auth: this.widget._auth,
    );

    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(child: CircularProgressIndicator());
    }

    List<Widget> children = [];

    children.add(TabBar(
      isScrollable: true,
      labelColor: Colors.black,
      indicatorColor: Colors.black,
      tabs: [
        Tab(text: 'Questions'),
        Tab(text: 'Quizzes'),
      ],
    ));

    // children.add(
    //   Row(
    //     children: [
    //       Flexible(
    //         child: TextButton(
    //           child: Text('Create new quiz'),
    //           onPressed: () {
    //             Navigator.push(
    //               this.context,
    //               MaterialPageRoute(builder: (BuildContext context) {
    //                 return QuizCreateForm(
    //                   moduleId: this.widget.moduleId,
    //                   firestore: this.widget._firestore,
    //                   auth: this.widget._auth,
    //                 );
    //               }),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );

    // this.questions.forEach((question) {
    //   List<Map<String, dynamic>> questionVotes =
    //       this.questionVotes[question['id']] == null
    //           ? []
    //           : this.questionVotes[question['id']]!;
    //   children.add(QuestionSummary(
    //     title: question['title'],
    //     questionId: question['id'],
    //     createdAt: question['createdAt'],
    //     answers: this.questionAnswers[question['id']]!,
    //     authorDisplayName: this.questionAuthors[question['id']]?['displayName'],
    //     tags: question['tags'],
    //     votes: questionVotes,
    //   ));
    // });
    // Map<String, dynamic> question = this.questions[index];

    return WitsOverflowScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: Column(
        children: [
          Flexible(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  shadowColor: Colors.white,
                  backgroundColor: Colors.white,
                  actions: [
                    Flexible(
                      child: TextButton(
                        child: Text('Create new quiz'),
                        onPressed: () {
                          Navigator.push(
                            this.context,
                            MaterialPageRoute(builder: (BuildContext context) {
                              return QuizCreateForm(
                                moduleId: this.widget.moduleId,
                                firestore: this.widget._firestore,
                                auth: this.widget._auth,
                              );
                            }),
                          );
                        },
                      ),
                    )
                  ],
                  bottom: TabBar(
                    isScrollable: true,
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    tabs: [
                      Tab(text: 'Questions'),
                      Tab(text: 'Quizzes'),
                      // Tab(text: 'My Posts'),
                    ],
                  ),
                  title: Text(
                    this.module['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    this.questionsTab,
                    this.quizzesTab,
                  ],
                ),
              ),
            ),
          ),

          // Container(
          //   child: TabBarView(
          //     children: [
          //       this.questionsTab,
          //       this.quizzesTab,
          //     ],
          //   ),
          // ),
        ],
      ),

      // Column(
      //   children: children,
      // ),
    );
  }
}

class QuizzesTab extends StatefulWidget {
  final String moduleId;

  late final _firestore;
  late final _auth;

  QuizzesTab({required this.moduleId, firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  State<StatefulWidget> createState() {
    return _QuizzesTabState();
  }
}

class _QuizzesTabState extends State<QuizzesTab> {
  WitsOverflowData witsOverflowData = WitsOverflowData();
  bool _loading = true;
  List<Map<String, dynamic>> quizzes = [];

  Future<void> getData() async {
    this
        .widget
        ._firestore
        .collection('quizzes')
        .where('moduleId', isEqualTo: this.widget.moduleId)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((quiz) {
        Map<String, dynamic> q = quiz.data();
        q.addAll({'id': quiz.id});
        this.quizzes.add(q);
      });

      this.setState(() {
        this._loading = false;
      });
    });
  }

  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // print('[QUIZZES TAB RETURNING QUIZZES INFORMATION]');
    List<Widget> children = [];

    for (int i = 0; i < this.quizzes.length; i++) {
      Map<String, dynamic> quiz = this.quizzes[i];
      children.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) {
                return AnswerQuizForm(quizId: quiz['id']);
              }),
            );
          },
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(
                color: Colors.grey,
                width: 0.3,
              ),
            ),
            child: Column(
                // title
                children: [
                  // title
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      quiz['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // number of questions
                  Container(
                      child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Due :',
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' ' +
                              formatDateTime(
                                  (quiz['dueDate'] as Timestamp).toDate()),
                          style: TextStyle(
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  )),
                ]),
          ),
        ),
      );
    }
    return Column(
      children: children,
    );
  }
}
