import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/forms/question_answer_form.dart';
import 'package:wits_overflow/forms/question_comment_form.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question.dart';
import 'package:wits_overflow/widgets/widgets.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:wits_overflow/widgets/answers.dart';
import 'package:wits_overflow/widgets/comments.dart';
// import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
//             Dashboard class
// ---------------------------------------------------------------------------
class QuestionAndAnswersScreen extends StatefulWidget {
  final String id; //question id

  late final _firestore; // = FirebaseFirestore.instance;
  late final _auth;

  QuestionAndAnswersScreen(this.id, {firestore, auth})
      : this._firestore = firestore == null
            ? firebase_core.FirebaseFirestore.instance
            : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<QuestionAndAnswersScreen> {
  late Map<String, dynamic> question;
  List<Map<String, dynamic>> questionAnswers = [];
  bool isBusy = true;
  WitsOverflowData witsOverflowData = WitsOverflowData();
  Widget? questionImage;

  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  Future<void> getData() async {
    this.question = (await witsOverflowData.fetchQuestion(this.widget.id))!;

    await witsOverflowData.fetchQuestionAnswers(this.widget.id).then((value) {
      if (value != null) {
        // print('[QUESTION : $question]');
        this.questionAnswers = value;
      }
    });

    if (this.question['image_url'] != null) {
      try {
        Uint8List? uint8list = await firebase_storage.FirebaseStorage.instance
            .ref(this.question['image_url'])
            .getData();
        if (uint8list != null) {
          this.questionImage = Image.memory(uint8list);
          // print(this.question['image_url']);
        } else {
          // print('[uint8list IS NULL]');
        }
      } on firebase_core.FirebaseException catch (e) {
        print('[FAILED TO FETCH QUESTION IMAGE, ERROR -> $e]');
      }
    }

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
                    imageURL: question['image_url'],
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
                  return getCircularProgressIndicator();
                }
              });
        } else if (snapshot.hasError) {
          return Text('Error occurred', style: TextStyle(color: Colors.red));
        } else {
          return getCircularProgressIndicator();
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
                      auth: widget._auth,
                      firestore: widget._firestore);
                } else if (commentsSnapshot.hasError) {
                  return Text('Error occurred',
                      style: TextStyle(color: Colors.red));
                } else {
                  return getCircularProgressIndicator();
                }
              });
        } else if (commentsSnapshot.hasError) {
          return Text('Error occurred', style: TextStyle(color: Colors.red));
        } else {
          return getCircularProgressIndicator();
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
                          imageURL: answers[i]['image_url'],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error occurred',
                            style: TextStyle(color: Colors.red));
                      } else {
                        return getCircularProgressIndicator();
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error occurred',
                      style: TextStyle(color: Colors.red));
                } else {
                  return getCircularProgressIndicator();
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
          return getCircularProgressIndicator();
        }
      },
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
          margin: EdgeInsets.fromLTRB(20, 15, 15, 0),
          child: ListView(
            children: <Widget>[
              /// question title and body
              /// votes, up-vote and down-vote

              this._buildQuestionWidget(),

              SizedBox(height: 20),

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
