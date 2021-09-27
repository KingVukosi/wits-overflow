import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM
// -----------------------------------------------------------------------------
class QuestionCommentForm extends StatefulWidget {
  final String questionId;

  final _firestore;
  final _auth;

  QuestionCommentForm({required this.questionId, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionCommentFormState createState() {
    return _QuestionCommentFormState();
  }
}

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM STATE
// -----------------------------------------------------------------------------
class _QuestionCommentFormState extends State<QuestionCommentForm> {
  final _formKey = GlobalKey<FormState>();

  bool isBusy = true;
  late final Map<String, dynamic>? question;

  final bodyController = TextEditingController();

  WitsOverflowData witsOverflowData = WitsOverflowData();

  void initState() {
    super.initState();
    witsOverflowData.initialize(
        firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  void getData() async {
    this.question =
        await witsOverflowData.fetchQuestion(this.widget.questionId);

    setState(() {
      this.isBusy = false;
    });
  }

  void submitComment(String body) async {
    print('[POSTING QUESTION COMMENT]');
    setState(() {
      isBusy = true;
    });

    String authorId = witsOverflowData.getCurrentUser()!.uid;
    Map<String, dynamic>? questionComment =
        await witsOverflowData.postQuestionComment(
            questionId: this.widget.questionId, body: body, authorId: authorId);

    if (questionComment == null) {
      showNotification(this.context, 'Something went wrong', type: 'error');
    } else {
      print('[SUCCESSFULLY POSTED QUESTION COMMENT]');
      showNotification(this.context, 'Successfully posted your comment');

      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return QuestionAndAnswersScreen(this.widget.questionId);
        },
      ));
    }

    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    if (this.isBusy) {
      return WitsOverflowScaffold(
        auth: this.widget._auth,
        firestore: this.widget._firestore,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WitsOverflowScaffold(
      auth: this.widget._auth,
      firestore: this.widget._firestore,
      body: ListView(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  // color: Colors.black12,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                        width: 0.5,
                      ),
                    ),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    this.question?['title'],
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(1000, 70, 70, 70),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  // color: Colors.black12,
                  child: Text(
                    this.question?['body'],
                    style: TextStyle(
                      color: Color.fromARGB(1000, 70, 70, 70),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
            color: Color.fromARGB(100, 220, 220, 220),
            child: Text(
              'Post comment',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(100, 16, 16, 16)),
            ),
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                // margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      // color:Color.fromARGB(1000, 100, 100, 100),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextFormField(
                        key: Key('id_edit_comment_body'),
                        controller: this.bodyController,
                        maxLines: 15,
                        minLines: 10,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Comment',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      // color:Color.fromARGB(1000, 100, 100, 100),
                      // alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: ElevatedButton(
                        key: Key('id_submit'),
                        onPressed: () {
                          print('[SUBMITTING QUESTION COMMENT]');
                          this.submitComment(bodyController.text.toString());
                        },
                        child: Text('post'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
