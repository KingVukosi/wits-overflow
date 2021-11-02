import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wits_overflow/forms/question_edit_form.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// import 'package:wits_overflow/forms/question_answer_form.dart';
// import 'package:wits_overflow/forms/question_comment_form.dart';
// import 'package:wits_overflow/startup/wits_overflow_app.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/widgets.dart';
// import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
// import 'package:wits_overflow/screens/question_and_answers_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class QuestionWidget extends StatefulWidget {
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

  final String? imageURL;

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
    this.imageURL,
  }) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    this
        .witsOverflowData
        .initialize(firestore: this._firestore, auth: this._auth);
  }

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  bool isBusy = true;
  Widget? questionImage;

  Future<void> getImage() async {
    // String iurl = this.widget.imageURL!;
    // print("imageURL: $iurl");
    if (this.widget.imageURL != null) {
      try {
        Uint8List? uint8list = await firebase_storage.FirebaseStorage.instance
            .ref(this.widget.imageURL)
            .getData();
        if (uint8list != null) {
          this.questionImage = Image.memory(uint8list);
          print(this.questionImage);
        } else {
          print('[uint8list IS NULL]');
        }
      } on firebase_core.FirebaseException catch (e) {
        print('[FAILED TO FETCH QUESTION IMAGE, ERROR -> $e]');
      }
    }

    setState(() {
      this.isBusy = false;
    });
  }

  void initState() {
    super.initState();
    this
        .widget
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    getImage();
    // print("Question Image: $questionImage");
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (this.isBusy) {
      Center(
        child: CircularProgressIndicator(),
      );
    }

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
                    width: 50,
                    // color: Color.fromRGBO(214, 217, 220, 0.2),
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          key: Key('id_question_${this.widget.id}_upvote_btn'),
                          onPressed: () {
                            WitsOverflowData().voteQuestion(
                              context: context,
                              value: 1,
                              questionId: this.widget.id,
                              userId:
                                  widget.witsOverflowData.getCurrentUser()!.uid,
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
                                  color: Color.fromRGBO(100, 100, 100, 0.2));
                            },
                            height: (1.9 / 100) * (size.width),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, (1 / 100) * size.width,
                              0, (1 / 100) * size.width),
                          child: Text(
                            // this.questionVotes!.docs.length.toString(),
                            this.widget.votes.toString(),
                            style: TextStyle(
                              // backgroundColor: Colors.black12,
                              fontSize: (2.7 / 100) * size.width,
                            ),
                          ),
                        ),
                        TextButton(
                          key:
                              Key('id_question_${this.widget.id}_downvote_btn'),
                          onPressed: () {
                            WitsOverflowData().voteQuestion(
                                context: context,
                                questionId: this.widget.id,
                                value: -1,
                                userId: widget.witsOverflowData
                                    .getCurrentUser()!
                                    .uid);
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
                                  color: Color.fromRGBO(100, 100, 100, 0.2));
                            },
                            height: (1.9 / 100) * (size.width),
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
                    this.widget.title,
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
          margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
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
            this.widget.body,
            // this.getQuestionBody(),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: 50,
                        height: 25,
                        child: TextButton(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(2)),
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
                    Flexible(
                      child: SizedBox(
                        width: 50,
                        height: 25,
                        child: TextButton(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(2)),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return QuestionEditForm(
                                  questionId: this.widget.id,
                                  firestore: this.widget._firestore,
                                  auth: this.widget._auth,
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: SizedBox(
                        width: 50,
                        height: 25,
                        child: TextButton(
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(2)),
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
                          .widget
                          .witsOverflowData
                          .addFavouriteQuestion(
                            userId:
                                widget.witsOverflowData.getCurrentUser()!.uid,
                            questionId: this.widget.id,
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

        this.questionImage == null
            ? Padding(padding: EdgeInsets.all(0))
            : Container(child: this.questionImage),
        this.questionImage == null
            ? Padding(padding: EdgeInsets.all(0))
            : Center(
                child: new RichText(
                  text: new TextSpan(
                    children: [
                      new TextSpan(
                        text: 'Click To Download Image',
                        style: new TextStyle(color: Colors.blue, fontSize: 20),
                        recognizer: new TapGestureRecognizer()
                          ..onTap = () {
                            launch(this.widget.imageURL!);
                          },
                      ),
                    ],
                  ),
                ),
              ),

        UserCard(
          createdAt: this.widget.createdAt,
          authorId: this.widget.authorId,
          authorDisplayName: widget.authorDisplayName,
          editorId: this.widget.editorId,
          editorDisplayName: this.widget.editorDisplayName,
          editedAt: this.widget.editedAt,
        )
      ],
    );
  }
}
