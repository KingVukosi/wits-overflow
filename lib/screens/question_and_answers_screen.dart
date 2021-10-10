import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/forms/question_answer_form.dart';
import 'package:wits_overflow/forms/question_comment_form.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:wits_overflow/widgets/answers.dart';
import 'package:wits_overflow/widgets/comments.dart';

// ---------------------------------------------------------------------------
//             Dashboard class
// ---------------------------------------------------------------------------
class QuestionAndAnswersScreen extends StatefulWidget {
  final String id; //question id

  late final _firestore; // = FirebaseFirestore.instance;
  late final _auth;

  QuestionAndAnswersScreen(this.id, {firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<QuestionAndAnswersScreen> {
  late Map<String, dynamic> question;

  List<Map<String, dynamic>> questionVotes = [];
  List<Map<String, dynamic>> questionComments = [];
  List<Map<String, dynamic>> questionAnswers = [];

  late Map<String, dynamic> questionAuthor;
  late Map<String, dynamic> questionEditor = {};

  // holds user information for each question comment
  // question comments (comments that belong to the question)
  // not answers
  Map<String, Map<String, dynamic>> questionCommentsAuthors =
      Map<String, Map<String, dynamic>>();

  // holds user information for each question answer
  Map<String, Map<String, dynamic>> questionAnswersAuthors =
      Map<String, Map<String, dynamic>>();

  // holds votes information for each answer
  Map<String, List<Map<String, dynamic>>> questionAnswersVotes =
      Map<String, List<Map<String, dynamic>>>();

  // holds votes information for each answer
  Map<String, Map<String, dynamic>> questionAnswerEditors =
      Map<String, Map<String, dynamic>>();

  Map<String, List<Map<String, dynamic>>> questionAnswersComments = {};

  // holds author information to each question-answer comments
  // hold author information for each comment that belongs to answers
  Map<String, Map<String, Map<String, dynamic>>>
      questionAnswersCommentsAuthors =
      {}; // = Map<String, Map<String, dynamic>>();

  bool isBusy = true;

  late WitsOverflowData witsOverflowData = WitsOverflowData();

  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  Future<void> getData() async {
    // retrieve necessary data from firebase to view this page

    // get votes information for each answer
    Future<Map<String, List<Map<String, dynamic>>>> getAnswerVotes() async {
      Map<String, List<Map<String, dynamic>>> answerVotes = Map();
      for (var i = 0; i < this.questionAnswers.length; i++) {
        List<Map<String, dynamic>>? votes =
            await witsOverflowData.fetchQuestionAnswerVotes(
                this.widget.id, this.questionAnswers[i]['id']);
        answerVotes.addAll({this.questionAnswers[i]['id']: votes!});
      }
      return answerVotes;
    }

    // get user information for each comment
    Future<Map<String, Map<String, dynamic>>> getCommentsUsers() async {
      Map<String, Map<String, dynamic>> commentsUsers = Map();
      for (var i = 0; i < this.questionComments.length; i++) {
        Map<String, dynamic>? user = await witsOverflowData
            .fetchUserInformation(this.questionComments[i]['authorId']);
        commentsUsers.addAll({this.questionComments[i]['id']: user!});
      }
      return commentsUsers;
    }

    // get user (author) information for each answer
    Future<Map<String, Map<String, dynamic>>> getAnswersUsers() async {
      Map<String, Map<String, dynamic>> answersUsers = Map();
      for (var i = 0; i < this.questionAnswers.length; i++) {
        Map<String, dynamic>? user = await witsOverflowData
            .fetchUserInformation(this.questionAnswers[i]['authorId']);
        answersUsers.addAll({this.questionAnswers[i]['id']: user!});
      }
      return answersUsers;
    }

    // for each answer, get user information the of the editor
    Future<Map<String, Map<String, dynamic>>> getAnswerEditors() async {
      Map<String, Map<String, dynamic>> editors = {};
      for (int i = 0; i < this.questionAnswers.length; i++) {
        String? editorId = this.questionAnswers[i]['editorId'];
        String answerId = this.questionAnswers[i]['id'];
        if (editorId != null) {
          Map<String, dynamic>? userInfo =
              await witsOverflowData.fetchUserInformation(editorId);
          if (userInfo != null) {
            editors.addAll({answerId: userInfo});
          }
        }
      }
      return editors;
    }

    // for each comment in question answers, get user information
    Future<Map<String, Map<String, Map<String, dynamic>>>>
        getAnswersCommentsAuthors() async {
      Map<String, Map<String, Map<String, dynamic>>> results = {};
      for (int k = 0; k < this.questionAnswersComments.entries.length; k++) {
        // key - answer id
        // value - list of comments
        // {
        //   answerId:
        //    {
        //      commentId: user information (Map)
        //    }
        // }

        // looping through the comments that belong to the current
        // answer (answer with id answerCommentEntry.key) in the iteration
        String answerId = this.questionAnswersComments.entries.elementAt(k).key;
        List<Map<String, dynamic>> answerComments =
            this.questionAnswersComments.entries.elementAt(k).value;
        Map<String, Map<String, dynamic>> commentsAuthors = {};
        for (int i = 0; i < answerComments.length; i++) {
          Map<String, dynamic> comment = answerComments[i];
          Map<String, dynamic>? userInfo =
              await witsOverflowData.fetchUserInformation(comment['authorId']);

          commentsAuthors.addAll({
            comment['id']: userInfo!,
          });
        }

        results.addAll({
          answerId: commentsAuthors,
        });
      }
      return results;
    }

    // for each answer, get comments
    Future<Map<String, List<Map<String, dynamic>>>> getAnswersComments() async {
      Map<String, List<Map<String, dynamic>>> answersComments = {};
      for (int i = 0; i < this.questionAnswers.length; i++) {
        List<Map<String, dynamic>>? answerComments = await this
            .witsOverflowData
            .fetchQuestionAnswerComments(
                questionId: this.widget.id,
                answerId: this.questionAnswers[i]['id']);
        answersComments.addAll({
          this.questionAnswers[i]['id']:
              answerComments == null ? [] : answerComments,
        });
      }
      return answersComments;
    }

    this.question = (await witsOverflowData.fetchQuestion(this.widget.id))!;
    this.questionAuthor = (await witsOverflowData
        .fetchUserInformation(this.question['authorId']))!;
    this.questionEditor = this.question['editorId'] == null
        ? {}
        : (await witsOverflowData
            .fetchUserInformation(this.question['editorId']))!;
    List<Map<String, dynamic>>? fQuestionVotes =
        await witsOverflowData.fetchQuestionVotes(this.widget.id);
    this.questionVotes.addAll(fQuestionVotes == null ? [] : fQuestionVotes);
    List<Map<String, dynamic>>? fQuestionComments =
        await witsOverflowData.fetchQuestionComments(this.widget.id);
    this
        .questionComments
        .addAll(fQuestionComments == null ? [] : fQuestionComments);
    List<Map<String, dynamic>>? fQuestionAnswers =
        await witsOverflowData.fetchQuestionAnswers(this.widget.id);
    this
        .questionAnswers
        .addAll(fQuestionAnswers == null ? [] : fQuestionAnswers);

    this.questionAnswersVotes = await getAnswerVotes();
    this.questionAnswersAuthors = await getAnswersUsers();
    this.questionAnswerEditors = await getAnswerEditors();
    this.questionCommentsAuthors = await getCommentsUsers();
    this.questionAnswersComments = await getAnswersComments();
    this.questionAnswersCommentsAuthors = await getAnswersCommentsAuthors();

    // stores information of the user that first asked the question
    setState(() {
      this.isBusy = false;
    });
  }

  Widget buildCommentsWidget() {
    return Comments(
      comments: this.questionComments,
      commentsAuthors: this.questionCommentsAuthors,
      onAddComments: () {
        // navigate to the question comment form screen
        Navigator.push(this.context,
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return QuestionCommentForm(questionId: this.widget.id);
        }));
      },
    );
  }

  Widget buildAnswersWidget() {
    List<Widget> answers = <Widget>[];
    for (var i = 0; i < this.questionAnswers.length; i++) {
      bool? accepted = this.questionAnswers[i]['accepted'];
      String answerId = this.questionAnswers[i]['id'];
      var editedAt = this.questionAnswers[i]['editedAt'];
      String authorDisplayName =
          this.questionAnswersAuthors[answerId]!['displayName'];
      List<Map<String, dynamic>>? votes =
          this.questionAnswersVotes[this.questionAnswers[i]['id']];
      String? editorDisplayName =
          this.questionAnswerEditors[answerId]?['displayName'];
      List<Map<String, dynamic>>? comments =
          this.questionAnswersComments[answerId];
      Map<String, Map<String, dynamic>>? commentsAuthors =
          this.questionAnswersCommentsAuthors[answerId];
      answers.add(
        Answer(
          id: this.questionAnswers[i]['id'],
          authorDisplayName: authorDisplayName,
          votes: votes == null ? [] : votes,
          body: this.questionAnswers[i]['body'],
          answeredAt: (this.questionAnswers[i]['answeredAt'] as Timestamp),
          accepted: accepted == null ? false : accepted,
          authorId: this.questionAnswers[i]['authorId'],
          questionId: this.question['id'],
          questionAuthorId: this.question['authorId'],
          editorId: this.questionAnswers[i]['editorId'],
          editorDisplayName: editorDisplayName,
          editedAt: editedAt,
          comments: comments == null ? [] : comments,
          commentsAuthors: commentsAuthors == null ? {} : commentsAuthors,
          firestore: this.widget._firestore,
          auth: this.widget._auth,
        ),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: answers,
      ),
    );
  }

  int _calculateVotes(List<Map<String, dynamic>> votes) {
    int v = 0;
    for (var i = 0; i < votes.length; i++) {
      v += (votes[i]['value']) as int;
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    if (this.isBusy) {
      return WitsOverflowScaffold(
        firestore: this.widget._firestore,
        auth: this.widget._auth,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WitsOverflowScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              /// question title and body
              /// votes, up-vote and down-vote
              QuestionWidget(
                id: this.widget.id,
                title: this.question['title'],
                body: this.question['body'],
                image: this.question['image'],
                votes: this._calculateVotes(this.questionVotes),
                createdAt: this.question['createdAt'],
                authorDisplayName: this.questionAuthor['displayName'],
                authorId: this.question['authorId'],
                editorId: this.question['editorId'],
                editedAt: this.question['editedAt'],
                editorDisplayName: this.questionEditor['editorDisplayName'],
                auth: this.widget._auth,
                firestore: this.widget._firestore,
              ),

              /// comments list
              this.buildCommentsWidget(),

              /// answers
              /// answers header
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(239, 240, 241, 1),
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(214, 217, 220, 1),
                    ),
                  ),
                ),
                // color: Color(0xff2980b9),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${this.questionAnswers.length.toString()} Answers',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return QuestionAnswerForm(
                                questionId: this.question['id'],
                                firestore: this.widget._firestore,
                                auth: this.widget._auth,
                              );
                            }),
                          );
                        },
                        child: Icon(Icons.add),
                      ),
                    )
                  ],
                ),
              ),

              /// answers list
              this.buildAnswersWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
