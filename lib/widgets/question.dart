import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// import 'package:wits_overflow/forms/question_answer_form.dart';
// import 'package:wits_overflow/forms/question_comment_form.dart';
// import 'package:wits_overflow/startup/wits_overflow_app.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/widgets.dart';
// import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
// import 'package:wits_overflow/screens/question_and_answers_screen.dart';

class QuestionWidget extends StatelessWidget {
  final int votes;
  final String id;
  final String title;
  final String body;
  final Timestamp createdAt;
  final String authorDisplayName;

  final String authorId;

  final String? editorId;
  final String? editorDisplayName;
  final Timestamp? editedAt;

  late final WitsOverflowData witsOverflowData = WitsOverflowData();
  late final _firestore;
  late final _auth;

  QuestionWidget({
    required this.id,
    required this.title,
    required this.body,
    required this.votes,
    required this.createdAt,
    required this.authorDisplayName,
    required this.authorId,
    this.editorId,
    this.editorDisplayName,
    this.editedAt,
    firestore,
    auth,
  }) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    this
        .witsOverflowData
        .initialize(firestore: this._firestore, auth: this._auth);
  }

  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  width: 1, color: Color.fromRGBO(228, 230, 232, 1.0)),
            ),
          ),
          // padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Row(
            children: <Widget>[
              /// up vote button, down vote button
              /// number of votes
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Color.fromRGBO(214, 217, 220, 0.2),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          key: Key('id_question_${this.id}_upvote_btn'),
                          onPressed: () {
                            WitsOverflowData().voteQuestion(
                              context: context,
                              value: 1,
                              questionId: this.id,
                              userId: witsOverflowData.getCurrentUser()!.uid,
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
                          // this.questionVotes!.docs.length.toString(),
                          this.votes.toString(),
                          style: TextStyle(
                              // backgroundColor: Colors.black12,
                              // fontSize: 20,
                              ),
                        ),
                        TextButton(
                          key: Key('id_question_${this.id}_downvote_btn'),
                          onPressed: () {
                            WitsOverflowData().voteQuestion(
                                context: context,
                                questionId: this.id,
                                value: -1,
                                userId: witsOverflowData.getCurrentUser()!.uid);
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
                      ],
                    ),
                  ),
                ],
              ),

              /// question title
              Expanded(
                child: Container(
                  // color: Colors.black12,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    this.title,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      // fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                    softWrap: true,
                  ),
                ),
              ),
            ],
          ),
        ),

        /// question body
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(100, 214, 217, 220),
              ),
            ),
          ),
          padding: EdgeInsets.all(15),
          child: Text(
            this.body,
            // this.getQuestionBody(),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
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
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            print('[SHARE ANSWER BUTTON PRESSED]');
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
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
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            print('[EDIT ANSWER BUTTON PRESSED]');
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
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
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            print('[FOLLOW ANSWER BUTTON PRESSED]');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: SizedBox(
                  width: 100,
                  height: 30,
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.favorite,
                      size: 17.5,
                    ),
                    label: Text(
                      "",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => {
                      this
                          .witsOverflowData
                          .addFavouriteQuestion(
                            userId: witsOverflowData.getCurrentUser()!.uid,
                            questionId: this.id,
                          )
                          .then((result) {
                        showNotification(context, 'Favourite added.');
                      })
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 0),
                      padding: EdgeInsets.all(1),
                      // backgroundColor: Colors.black12,
                      primary: Color.fromRGBO(32, 141, 149, 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        UserCard(
          createdAt: this.createdAt,
          authorId: this.authorId,
          authorDisplayName: authorDisplayName,
          editorId: this.editorId,
          editorDisplayName: this.editorDisplayName,
          editedAt: this.editedAt,
        )
      ],
    );
  }
}
