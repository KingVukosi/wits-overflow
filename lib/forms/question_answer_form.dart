import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import 'package:wits_overflow/utils/exceptions.dart';

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM
// -----------------------------------------------------------------------------
class QuestionAnswerForm extends StatefulWidget {
  final String questionId;
  final String questionTitle;
  final String questionBody;

  final _firestore;
  final _auth;

  QuestionAnswerForm(this.questionId, this.questionTitle, this.questionBody,
      {firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionAnswerFormState createState() {
    return _QuestionAnswerFormState(
        this.questionId, this.questionTitle, this.questionBody,
        firestore: this._firestore, auth: this._auth);
  }
}

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM STATE
// -----------------------------------------------------------------------------
class _QuestionAnswerFormState extends State<QuestionAnswerForm> {
  final _formKey = GlobalKey<FormState>();
  final String questionId;
  final String questionTitle;
  final String questionBody;

  bool isBusy = true;
  Map<String, dynamic>? question;

  final bodyController = TextEditingController();

  late var _firestore;
  late var _auth;
  WitsOverflowData witsOverflowData = WitsOverflowData();

  _QuestionAnswerFormState(
      this.questionId, this.questionTitle, this.questionBody,
      {firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
    this.getData();
  }

  void getData() async {
    this.question = await witsOverflowData.fetchQuestion(this.questionId);

    setState(() {
      this.isBusy = false;
    });
  }

  Future<void> submitAnswer(String body) async {
    setState(() {
      isBusy = true;
    });

    try {
      String authorId = witsOverflowData.getCurrentUser()!.uid;
      Map<String, dynamic>? answer = await witsOverflowData.postAnswer(
          questionId: this.questionId, authorId: authorId, body: body);

      if (answer == null) {
        showNotification(this.context, 'Something went wrong', type: 'error');
      } else {
        showNotification(this.context, 'Successfully posted your answer');

        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return QuestionAndAnswersScreen(this.questionId);
          },
        ));
      }
    } on UseQuestionAnswerExist {
      showNotification(
          this.context, 'You have existing answer for this question',
          type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: include courses dropdown list
    if (this.isBusy) {
      print('[_QuestionAnswerFormState-> PAGE IS LOADING]');
      return WitsOverflowScaffold(
        auth: this._auth,
        firestore: this._firestore,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    print('[_QuestionAnswerFormState-> BUILDING PAGE]');
    return WitsOverflowScaffold(
      auth: this._auth,
      firestore: this._firestore,
      body: ListView(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.black12,
                      width: 0.5,
                    )),
                  ),
                  child: Text(
                    toTitleCase(this.questionTitle),
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(1000, 70, 70, 70),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Text(
                    this.questionBody,
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
              'Post answer',
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
                        controller: this.bodyController,
                        maxLines: 15,
                        minLines: 10,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'answer',
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
                        onPressed: () {
                          // when the user wants to submit his/her answer to the question
                          // if(submitAnswer(bodyController.text.toString()) != null){
                          //   // redirect to question page
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context){
                          //         return Question(this.questionId);
                          //       }
                          //     ),
                          //   );
                          // }

                          this.submitAnswer(
                              this.bodyController.text.toString());
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
