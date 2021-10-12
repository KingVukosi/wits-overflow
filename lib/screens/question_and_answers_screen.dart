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
  //
  // List<Map<String, dynamic>> questionVotes = [];
  // List<Map<String, dynamic>> questionComments = [];
  List<Map<String, dynamic>> questionAnswers = [];
  //
  // late Map<String, dynamic> questionAuthor;
  // late Map<String, dynamic> questionEditor = {};
  //
  // // holds user information for each question comment
  // // question comments (comments that belong to the question)
  // // not answers
  // Map<String, Map<String, dynamic>> questionCommentsAuthors =
  //     Map<String, Map<String, dynamic>>();
  //
  // // holds user information for each question answer
  // Map<String, Map<String, dynamic>> questionAnswersAuthors =
  //     Map<String, Map<String, dynamic>>();
  //
  // // holds votes information for each answer
  // Map<String, List<Map<String, dynamic>>> questionAnswersVotes =
  //     Map<String, List<Map<String, dynamic>>>();
  //
  // // holds votes information for each answer
  // Map<String, Map<String, dynamic>> questionAnswerEditors =
  //     Map<String, Map<String, dynamic>>();
  //
  // Map<String, List<Map<String, dynamic>>> questionAnswersComments = {};
  //
  // // holds author information to each question-answer comments
  // // hold author information for each comment that belongs to answers
  // Map<String, Map<String, Map<String, dynamic>>>
  //     questionAnswersCommentsAuthors =
  //     {}; // = Map<String, Map<String, dynamic>>();

  bool isBusy = true;

  WitsOverflowData witsOverflowData = WitsOverflowData();

  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  Future<void> getData() async {
    // retrieve necessary data from firebase to view this page
    //
    // // get votes information for each answer
    // Future<Map<String, List<Map<String, dynamic>>>> getAnswerVotes() async {
    //   Map<String, List<Map<String, dynamic>>> answerVotes = Map();
    //   for (var i = 0; i < this.questionAnswers.length; i++) {
    //     List<Map<String, dynamic>>? votes =
    //         await witsOverflowData.fetchQuestionAnswerVotes(
    //             this.widget.id, this.questionAnswers[i]['id']);
    //     answerVotes.addAll({this.questionAnswers[i]['id']: votes!});
    //   }
    //   return answerVotes;
    // }
    //
    // // get user information for each comment
    // Future<Map<String, Map<String, dynamic>>> getQuestionCommentsAuthors() async {
    //   Map<String, Map<String, dynamic>> commentsUsers = Map();
    //   for (var i = 0; i < this.questionComments.length; i++) {
    //     Map<String, dynamic>? user = await witsOverflowData
    //         .fetchUserInformation(this.questionComments[i]['authorId']);
    //     commentsUsers.addAll({this.questionComments[i]['id']: user!});
    //   }
    //   return commentsUsers;
    // }
    //
    // // get user (author) information for each answer
    // Future<Map<String, Map<String, dynamic>>> getQuestionAnswersAuthors() async {
    //   Map<String, Map<String, dynamic>> answersUsers = Map();
    //   for (var i = 0; i < this.questionAnswers.length; i++) {
    //     Map<String, dynamic>? user = await witsOverflowData
    //         .fetchUserInformation(this.questionAnswers[i]['authorId']);
    //     answersUsers.addAll({this.questionAnswers[i]['id']: user!});
    //   }
    //   return answersUsers;
    // }
    //
    // // for each answer, get user information the of the editor
    // Future<Map<String, Map<String, dynamic>>> getAnswerEditors() async {
    //   Map<String, Map<String, dynamic>> editors = {};
    //   for (int i = 0; i < this.questionAnswers.length; i++) {
    //     String? editorId = this.questionAnswers[i]['editorId'];
    //     String answerId = this.questionAnswers[i]['id'];
    //     if (editorId != null) {
    //       Map<String, dynamic>? userInfo =
    //           await witsOverflowData.fetchUserInformation(editorId);
    //       if (userInfo != null) {
    //         editors.addAll({answerId: userInfo});
    //       }
    //     }
    //   }
    //   return editors;
    // }
    //
    // // for each comment in question answers, get user information
    // Future<Map<String, Map<String, Map<String, dynamic>>>>
    //     getAnswersCommentsAuthors() async {
    //   Map<String, Map<String, Map<String, dynamic>>> results = {};
    //   for (int k = 0; k < this.questionAnswersComments.entries.length; k++) {
    //     // key - answer id
    //     // value - list of comments
    //     // {
    //     //   answerId:
    //     //    {
    //     //      commentId: user information (Map)
    //     //    }
    //     // }
    //
    //     // looping through the comments that belong to the current
    //     // answer (answer with id answerCommentEntry.key) in the iteration
    //     String answerId = this.questionAnswersComments.entries.elementAt(k).key;
    //     List<Map<String, dynamic>> answerComments =
    //         this.questionAnswersComments.entries.elementAt(k).value;
    //     Map<String, Map<String, dynamic>> commentsAuthors = {};
    //     for (int i = 0; i < answerComments.length; i++) {
    //       Map<String, dynamic> comment = answerComments[i];
    //       Map<String, dynamic>? userInfo =
    //           await witsOverflowData.fetchUserInformation(comment['authorId']);
    //
    //       commentsAuthors.addAll({
    //         comment['id']: userInfo!,
    //       });
    //     }
    //
    //     results.addAll({
    //       answerId: commentsAuthors,
    //     });
    //   }
    //   return results;
    // }
    //
    // // for each answer, get comments
    // Future<Map<String, List<Map<String, dynamic>>>> getAnswersComments() async {
    //   Map<String, List<Map<String, dynamic>>> answersComments = {};
    //   for (int i = 0; i < this.questionAnswers.length; i++) {
    //     List<Map<String, dynamic>>? answerComments = await this
    //         .witsOverflowData
    //         .fetchQuestionAnswerComments(
    //             questionId: this.widget.id,
    //             answerId: this.questionAnswers[i]['id']);
    //     answersComments.addAll({
    //       this.questionAnswers[i]['id']:
    //           answerComments == null ? [] : answerComments,
    //     });
    //   }
    //   return answersComments;
    // }
    //
    this.question = (await witsOverflowData.fetchQuestion(this.widget.id))!;
    // print('[QUESTION: $question]');
    // this.questionAuthor = witsOverflowData.fetchUserInformation(this.question['authorId']);
    // this.questionEditor = this.question['editorId'] == null
    //     ? {}
    //     : (await witsOverflowData
    //         .fetchUserInformation(this.question['editorId']))!;
    //
    // this.questionVotes = witsOverflowData.fetchQuestionVotes(this.widget.id);
    //
    // FutureBuilder(
    //   future: Future.wait([
    //     witsOverflowData.fetchQuestion(this.widget.id),
    //     witsOverflowData.fetchUserInformation(this.question['authorId']),
    //   ]),
    //   builder: (){
    //
    //   }
    // );
    // this.questionComments = witsOverflowData.fetchQuestionComments(this.widget.id);
    await witsOverflowData.fetchQuestionAnswers(this.widget.id).then((value) {
      if (value != null) {
        this.questionAnswers = value;
      }
    });
    // this.questionAnswers = fQuestionAnswers == null ? [];
    //
    // this.questionAnswersVotes = getAnswerVotes();
    // this.questionAnswersAuthors = getQuestionAnswersAuthors();
    // this.questionAnswerEditors = getAnswerEditors();
    // this.questionCommentsAuthors = getQuestionCommentsAuthors();
    // this.questionAnswersComments = getAnswersComments();
    // this.questionAnswersCommentsAuthors = getAnswersCommentsAuthors();

    // stores information of the user that first asked the question
    setState(() {
      this.isBusy = false;
    });
  }

  Widget _buildQuestionWidget() {
    return FutureBuilder(
      future:
          Future.wait([witsOverflowData.fetchQuestionVotes(this.widget.id)]),
      builder: (BuildContext context, AsyncSnapshot<List<Object?>> snapshot) {
        if (snapshot.hasData) {
          // Map<String, dynamic> question = snapshot.data![0] as  Map<String, dynamic>;
          // Map<String, dynamic> questionAuthor = snapshot.data![0] as Map<String, dynamic>;
          List<Map<String, dynamic>> questionVotes =
              snapshot.data![0] as List<Map<String, dynamic>>;

          List<Future> future = [
            witsOverflowData.fetchUserInformation(this.question['authorId'])
          ];
          if (this.question['editorId'] != null) {
            future.add(witsOverflowData
                .fetchUserInformation(this.question['editorId']));
          }

          return FutureBuilder(
              future: Future.wait(future),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> questionAuthor = snapshot.data![0];
                  Map<String, dynamic> questionEditor = {};
                  if (snapshot.data!.length > 1) {
                    questionEditor = snapshot.data![0];
                  }

                  return QuestionWidget(
                    id: this.widget.id,
                    title: question['title'],
                    body: question['body'],
                    votes: this._calculateVotes(questionVotes),
                    createdAt: question['createdAt'],
                    authorDisplayName: questionAuthor['displayName'],
                    authorId: question['authorId'],
                    editorId: question['editorId'],
                    editedAt: question['editedAt'],
                    editorDisplayName: questionEditor['editorDisplayName'],
                    auth: widget._auth,
                    firestore: widget._firestore,
                  );
                } else if (snapshot.hasError) {
                  return Text('Error occurred',
                      style: TextStyle(color: Colors.red));
                } else {
                  return CircularProgressIndicator(
                    color: Color.fromRGBO(100, 100, 100, 0.5),
                  );
                }
              });
        } else if (snapshot.hasError) {
          return Text('Error occurred', style: TextStyle(color: Colors.red));
        } else {
          return CircularProgressIndicator(
            color: Color.fromRGBO(100, 100, 100, 0.5),
          );
          // return Padding(padding: EdgeInsets.all(0));
        }
      },
    );
  }

  Widget _buildCommentsWidget() {
    return FutureBuilder(
      future: this.witsOverflowData.fetchQuestionComments(this.widget.id),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>?> commentsSnapshot) {
        if (commentsSnapshot.hasData) {
          List<Map<String, dynamic>> comments = commentsSnapshot.data!;
          List<Future> futures = [];
          for (int i = 0; i < comments.length; i++) {
            futures.add(this
                .witsOverflowData
                .fetchUserInformation(comments[i]['authorId']));
          }

          return FutureBuilder(
              future: Future.wait(futures),
              // builder
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> fCommentAuthors) {
                if (fCommentAuthors.hasData) {
                  Map<String, Map<String, dynamic>> commentAuthors = {};
                  for (int i = 0; i < comments.length; i++) {
                    commentAuthors.addAll({
                      comments[i]['id']: fCommentAuthors.data![i],
                    });
                  }
                  return Comments(
                    comments: comments,
                    commentsAuthors: commentAuthors,
                    onAddComments: () {
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(builder: (BuildContext context) {
                          return QuestionCommentForm(
                              questionId: this.widget.id);
                        }),
                      );
                    },
                  );
                } else if (commentsSnapshot.hasError) {
                  return Text('Error occurred',
                      style: TextStyle(color: Colors.red));
                } else {
                  return CircularProgressIndicator(
                    color: Color.fromRGBO(100, 100, 100, 0.5),
                  );
                }
              });
        } else if (commentsSnapshot.hasError) {
          return Text('Error occurred', style: TextStyle(color: Colors.red));
        } else {
          return CircularProgressIndicator(
            color: Color.fromRGBO(100, 100, 100, 0.5),
          );
        }
      },
    );
  }

  Widget _buildAnswersWidget() {
    return FutureBuilder(
      future: witsOverflowData.fetchQuestionAnswers(this.widget.id),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>?> snapshot) {
        // answer votes
        // answer author
        // answer editor
        // answer comments

        if (snapshot.hasData) {
          List<Map<String, dynamic>> answers = snapshot.data!;
          List<Widget> widgetComments = [];
          for (int i = 0; i < snapshot.data!.length; i++) {
            List<Future> future = [
              this
                  .witsOverflowData
                  .fetchUserInformation(answers[i]['authorId']),
              this.witsOverflowData.fetchQuestionAnswerComments(
                  questionId: this.widget.id, answerId: answers[i]['id']),
              this
                  .witsOverflowData
                  .fetchQuestionAnswerVotes(this.widget.id, answers[i]['id']),
              this.witsOverflowData.fetchQuestion(this.widget.id),
            ];

            if (answers[i]['editorId'] != null) {
              future.add(this
                  .witsOverflowData
                  .fetchUserInformation(answers[i]['authorId']));
            }
            widgetComments.add(FutureBuilder(
              future: Future.wait(future),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> author = snapshot.data![0];
                  List<Map<String, dynamic>> comments = snapshot.data![1];
                  List<Map<String, dynamic>> votes = snapshot.data![2];
                  Map<String, dynamic> question = snapshot.data![3];
                  Map<String, dynamic> editor = {};
                  if (snapshot.data!.length > 4) {
                    editor = snapshot.data![4];
                  }

                  List<Future> futures = comments.map((answerComment) {
                    return this
                        .witsOverflowData
                        .fetchUserInformation(answerComment['authorId']);
                  }).toList();

                  return FutureBuilder(
                    future: Future.wait(futures),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.hasData) {
                        Map<String, Map<String, dynamic>> commentsAuthors = {};
                        for (int i = 0; i < comments.length; i++) {
                          commentsAuthors
                              .addAll({comments[i]['id']: snapshot.data![i]});
                        }
                        print('[BUILDING ANSWER WIDGETS ->\n'
                            'ANSWERS[$i]: ${answers[i]}\n'
                            'AUTHOR: $author\n'
                            'EDITOR: $editor]\n');
                        return Answer(
                          id: answers[i]['id'],
                          body: answers[i]['body'],
                          answeredAt: answers[i]['answeredAt'],
                          votes: votes,
                          accepted: answers[i]['accepted'] == null
                              ? false
                              : answers[i]['accepted'],
                          authorId: author['id'],
                          authorDisplayName: author['displayName'],
                          questionId: this.widget.id,
                          questionAuthorId: question['authorId'],
                          comments: comments,
                          commentsAuthors: commentsAuthors,
                          editorId: editor['id'],
                          editedAt: answers[i]['editedAt'],
                          editorDisplayName: editor['displayName'],
                          firestore: this.widget._firestore,
                          auth: this.widget._auth,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error occurred',
                            style: TextStyle(color: Colors.red));
                      } else {
                        return CircularProgressIndicator(
                          color: Color.fromRGBO(100, 100, 100, 0.5),
                        );
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error occurred',
                      style: TextStyle(color: Colors.red));
                } else {
                  return CircularProgressIndicator(
                    color: Color.fromRGBO(100, 100, 100, 0.5),
                  );
                }
              },
            ));
          }
          return Column(
            children: [
              Column(
                children: widgetComments,
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error occurred', style: TextStyle(color: Colors.red));
        } else {
          return CircularProgressIndicator(
            color: Color.fromRGBO(100, 100, 100, 0.5),
          );
        }
      },
    );

    // List<Widget> answers = <Widget>[];
    // for (var i = 0; i < this.questionAnswers.length; i++) {
    //   bool? accepted = this.questionAnswers[i]['accepted'];
    //   String answerId = this.questionAnswers[i]['id'];
    //   var editedAt = this.questionAnswers[i]['editedAt'];
    //   String authorDisplayName =
    //       this.questionAnswersAuthors[answerId]!['displayName'];
    //   List<Map<String, dynamic>>? votes =
    //       this.questionAnswersVotes[this.questionAnswers[i]['id']];
    //   String? editorDisplayName =
    //       this.questionAnswerEditors[answerId]?['displayName'];
    //   List<Map<String, dynamic>>? comments =
    //       this.questionAnswersComments[answerId];
    //   Map<String, Map<String, dynamic>>? commentsAuthors =
    //       this.questionAnswersCommentsAuthors[answerId];
    //   answers.add(
    //     Answer(
    //       id: this.questionAnswers[i]['id'],
    //       authorDisplayName: authorDisplayName,
    //       votes: votes == null ? [] : votes,
    //       body: this.questionAnswers[i]['body'],
    //       answeredAt: (this.questionAnswers[i]['answeredAt'] as Timestamp),
    //       accepted: accepted == null ? false : accepted,
    //       authorId: this.questionAnswers[i]['authorId'],
    //       questionId: this.question['id'],
    //       questionAuthorId: this.question['authorId'],
    //       editorId: this.questionAnswers[i]['editorId'],
    //       editorDisplayName: editorDisplayName,
    //       editedAt: editedAt,
    //       comments: comments == null ? [] : comments,
    //       commentsAuthors: commentsAuthors == null ? {} : commentsAuthors,
    //       firestore: this.widget._firestore,
    //       auth: this.widget._auth,
    //     ),
    //   );
    // }

    // return Container(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: answers,
    //   ),
    // );
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
          margin: EdgeInsets.fromLTRB(20, 15, 15, 0),
          child: ListView(
            children: <Widget>[
              /// question title and body
              /// votes, up-vote and down-vote

              this._buildQuestionWidget(),
              // QuestionWidget(
              //   id: this.widget.id,
              //   title: this.question['title'],
              //   body: this.question['body'],
              //   votes: this._calculateVotes(this.questionVotes),
              //   createdAt: this.question['createdAt'],
              //   authorDisplayName: this.questionAuthor['displayName'],
              //   authorId: this.question['authorId'],
              //   editorId: this.question['editorId'],
              //   editedAt: this.question['editedAt'],
              //   editorDisplayName: this.questionEditor['editorDisplayName'],
              //   auth: this.widget._auth,
              //   firestore: this.widget._firestore,
              // ),

              /// comments list
              this._buildCommentsWidget(),

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
              this._buildAnswersWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
