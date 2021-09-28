import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wits_overflow/forms/question_answer_comment_form.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// import 'package:wits_overflow/forms/question_answer_form.dart';
// import 'package:wits_overflow/forms/question_comment_form.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
// import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/forms/answer_edit_form.dart';
import 'package:wits_overflow/widgets/comments.dart';
import 'package:wits_overflow/widgets/widgets.dart';

class Answer extends StatefulWidget {
  final String questionId;
  final String id;
  final String body;
  final List<Map<String, dynamic>> votes;
  final bool accepted;
  final String authorId;
  final String authorDisplayName;
  final Timestamp answeredAt;
  final String questionAuthorId;

  final String? editorId;
  final String? editorDisplayName;
  final Timestamp? editedAt;
  final List<Map<String, dynamic>> comments;
  final Map<String, Map<String, dynamic>> commentsAuthors;

  final _firestore;
  final _auth;

  Answer({
    required this.id,
    required this.body,
    required this.answeredAt,
    required this.votes,
    required this.accepted,
    required this.authorId,
    required this.authorDisplayName,
    required this.questionId,
    required this.questionAuthorId,
    this.comments = const [],
    this.commentsAuthors = const {},
    this.editorDisplayName,
    this.editedAt,
    this.editorId,
    firestore,
    auth,
  })  : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  bool isBusy = true;

  late Map<String, dynamic>? answer;

  WitsOverflowData witsOverflowData = WitsOverflowData();

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  void changeAnswerStatus({required String answerId}) async {
    // if the user is the author of the question

    // retrieve answer from database
    CollectionReference<Map<String, dynamic>> questionAnswersCollection =
        FirebaseFirestore.instance
            .collection('questions-2')
            .doc(this.widget.id)
            .collection('answers');
    DocumentSnapshot<Map<String, dynamic>> answer =
        await questionAnswersCollection.doc(answerId).get();

    bool accepted = (answer.data()!['accepted'] == null)
        ? false
        : answer.data()!['accepted'];

    bool value = false;
    if (accepted == true) {
      // change answer
      value = false;
    } else {
      value = true;
      // all other answer should change status
      QuerySnapshot<Map<String, dynamic>> acceptedAnswer =
          await questionAnswersCollection
              .where('accepted', isEqualTo: true)
              .get();
      for (var i = 0; i < acceptedAnswer.docs.length; i++) {
        acceptedAnswer.docs.elementAt(i).reference.update({'accepted': false});
      }
    }

    answer.reference.update({'accepted': value}).then((value) {
      showNotification(context, 'Changed answer status');
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return QuestionAndAnswersScreen(this.widget.id);
      })).catchError((error) {
        showNotification(context, 'Error occurred');
      });
    });
  }

  void getData() async {
    witsOverflowData.initialize(
        firestore: this.widget._firestore, auth: this.widget._auth);
    this.answer = await witsOverflowData.fetchAnswer(
        questionId: this.widget.questionId, answerId: this.widget.id);

    this.setState(() {
      this.isBusy = false;
    });
  }

  Widget getAnswerStatus() {
    if (this.widget.accepted == true) {
      // if answer is correct
      return GestureDetector(
        onTap: () {
          this.changeAnswerStatus(answerId: this.widget.id);
        },
        child: SvgPicture.asset(
          'assets/icons/answer_correct.svg',
          semanticsLabel: 'Feed button',
          placeholderBuilder: (context) {
            return Icon(Icons.error, color: Colors.deepOrange);
          },
          height: 25,
        ),
      );
    } else {
      if (this.widget.authorId == this.witsOverflowData.getCurrentUser()?.uid) {
        return GestureDetector(
          onTap: () {
            this.changeAnswerStatus(answerId: this.widget.id);
          },
          child: SvgPicture.asset(
            'assets/icons/answer_correct_placeholder.svg',
            semanticsLabel: 'Feed button',
            placeholderBuilder: (context) {
              return Icon(Icons.error, color: Colors.deepOrange);
            },
            height: 25,
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsets.all(0),
        );
      }
    }
  }

  Widget getAnswerStatusWidget() {
    /// return appropriate widget depending on whether the answer is accepted or not
    if (this.widget.accepted == true) {
      // // if answer is correct
      return GestureDetector(
        onTap: () {
          this.changeAnswerStatus(answerId: this.widget.id);
        },
        child: SvgPicture.asset(
          'assets/icons/answer_correct.svg',
          semanticsLabel: 'Feed button',
          placeholderBuilder: (context) {
            return Icon(Icons.error, color: Colors.deepOrange);
          },
          height: 25,
        ),
      );
    } else {
      if (this.widget.questionAuthorId ==
          this.witsOverflowData.getCurrentUser()?.uid) {
        return GestureDetector(
          onTap: () {
            this.changeAnswerStatus(answerId: this.widget.id);
          },
          child: SvgPicture.asset(
            'assets/icons/answer_correct_placeholder.svg',
            semanticsLabel: 'Feed button',
            placeholderBuilder: (context) {
              return Icon(Icons.error, color: Colors.deepOrange);
            },
            height: 25,
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsets.all(0),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// update vote button, down vote button, votes, question body
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(239, 240, 241, 1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              children: [
                /// answer up vote button, down vote button, votes vote button
                Expanded(
                  flex: 0,
                  child: Container(
                    color: Color.fromRGBO(239, 240, 241, 1),
                    child: Column(
                      children: <Widget>[
                        TextButton(
                          key: Key('answer_${this.widget.id}_upvote_btn'),
                          onPressed: () {
                            witsOverflowData.voteAnswer(
                              context: context,
                              value: 1,
                              answerId: this.widget.id,
                              userId: witsOverflowData.getCurrentUser()!.uid,
                              questionId: this.widget.questionId,
                            );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, 0),
                            padding: EdgeInsets.all(0.5),
                            // backgroundColor: Colors.black12,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/caret_up.svg',
                            semanticsLabel: 'Feed button',
                            placeholderBuilder: (context) {
                              return Icon(Icons.error,
                                  color: Colors.deepOrange);
                            },
                            height: 12.5,
                          ),
                        ),

                        Text(
                          countVotes(this.widget.votes).toString(),
                          style: TextStyle(
                              // backgroundColor: Colors.black12,
                              // fontSize: 20,
                              ),
                        ),

                        TextButton(
                          key: Key('answer_${this.widget.id}_downvote_btn'),
                          onPressed: () {
                            witsOverflowData.voteAnswer(
                              context: context,
                              answerId: this.widget.id,
                              value: -1,
                              userId: witsOverflowData.getCurrentUser()!.uid,
                              questionId: this.widget.questionId,
                            );
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, 0),
                            padding: EdgeInsets.all(0.5),
                            // backgroundColor: Colors.black12,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/caret_down.svg',
                            semanticsLabel: 'Feed button',
                            placeholderBuilder: (context) {
                              return Icon(Icons.error,
                                  color: Colors.deepOrange);
                            },
                            height: 12.5,
                          ),
                        ),

                        // answer status
                        getAnswerStatus(),
                      ],
                    ),
                  ),
                ),

                /// answer body
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      this.widget.body,
                      textAlign: TextAlign.left,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 50,
                  height: 25,
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(2)),
                      // backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () {
                      print('[SHARE ANSWER BUTTON PRESSED]');
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 25,
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(2)),
                      // backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext buildContext) {
                        return AnswerEditForm(
                          questionId: this.widget.questionId,
                          body: this.widget.body,
                          answerId: this.widget.id,
                          firestore: this.widget._firestore,
                          auth: this.widget._auth,
                        );
                      }));
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 25,
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(2)),
                      // backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: Text(
                      'Follow',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    onPressed: () {
                      print('[SHARE ANSWER BUTTON PRESSED]');
                    },
                  ),
                ),
              ],
            ),
          ),

          UserCard(
            authorId: this.widget.authorId,
            authorDisplayName: this.widget.authorDisplayName,
            createdAt: this.widget.answeredAt,
            editorId: this.widget.editorId,
            editorDisplayName: this.widget.editorDisplayName,
            editedAt: this.widget.editedAt,
          ),

          // /// author information
          // Container(
          //   decoration: BoxDecoration(
          //     color: Color.fromRGBO(240, 248, 225, 1),
          //     border: Border(
          //       bottom: BorderSide(
          //         width: 0.5,
          //         color: Color.fromRGBO(239, 240, 241, 1),
          //       ),
          //     ),
          //   ),
          //   padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       // user information
          //       Container(
          //         child: Row(
          //           children: [
          //             // user avatar image
          //             Container(
          //                 child: Image(
          //                     height: 25,
          //                     width: 25,
          //                     image: AssetImage(
          //                         'assets/images/default_avatar.png'))),
          //
          //             // user information (display name, metadata)
          //             Column(
          //               children: [
          //                 // user display name
          //                 Text(this.authorDisplayName,
          //                     // this.answersUsers[answerId]!.get('displayName'),
          //                     style: TextStyle(
          //                       color: Colors.blue,
          //                     )),
          //                 // user metadata
          //                 Row(
          //                   children: [],
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //
          //       // datetime
          //       Container(
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           crossAxisAlignment: CrossAxisAlignment.end,
          //           children: [
          //             Text(
          //               'answered at',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w600,
          //                 // backgroundColor: Colors.black12,
          //               ),
          //             ),
          //             Text(
          //               formatDateTime(this.answeredAt.toDate()),
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w600,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          //
          // /// editor information
          // this._getEditorCard(),

          // comments
          Container(
            child: Comments(
              comments: this.widget.comments,
              commentsAuthors: this.widget.commentsAuthors,
              onAddComments: () {
                // navigate to the question answer comment form
                Navigator.push(this.context,
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return QuestionAnswerCommentForm(
                      questionId: this.widget.questionId,
                      answerId: this.widget.id);
                }));
              },
            ),
          ),
        ],
      ),
    );
  }
}
