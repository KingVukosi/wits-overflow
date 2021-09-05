import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM
// -----------------------------------------------------------------------------
class QuestionAnswerForm extends StatefulWidget {
  final String questionId;
  final String questionTitle;
  final String questionBody;

  QuestionAnswerForm(this.questionId, this.questionTitle, this.questionBody);

  @override
  _QuestionAnswerFormState createState() {
    return _QuestionAnswerFormState(
        this.questionId, this.questionTitle, this.questionBody);
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
  DocumentSnapshot<Map<String, dynamic>>? question;

  final bodyController = TextEditingController();

  void getData() async {
    this.question = await FirebaseFirestore.instance
        .collection('questions-2')
        .doc(this.questionId)
        .get();

    setState(() {
      this.isBusy = false;
    });
  }

  _QuestionAnswerFormState(
      this.questionId, this.questionTitle, this.questionBody) {
    this.getData();
  }

  void submitAnswer(String body) {
    setState(() {
      isBusy = true;
    });

    Map<String, dynamic> data = {
      'authorId': FirebaseAuth.instance.currentUser!.uid,
      'body': body,
      'answeredAt': DateTime.now(),
    };

    CollectionReference questionAnswersCollection = FirebaseFirestore.instance
        .collection('questions-2')
        .doc(this.questionId)
        .collection('answers');
    questionAnswersCollection.add(data).then((onValue) {
      print("[QUESTION ADDED]");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully posted answer',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ),
      );

      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return QuestionAndAnswersScreen(this.questionId);
        },
      ));
    }).catchError((error) {
      // if error occurs while submitting user answer
      print("[FAILED TO ADD QUESTION]: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error occurred',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    });
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.

    // TODO: include courses dropdown list

    if (this.isBusy) {
      return WitsOverflowScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // for (var dropdownMenuItem in this.dropdownButtonMenuItems) {
    //   print('[QuestionCreateFormState.build dropDownMenuItem: text: ${dropdownMenuItem.child.toString()}, value: ${dropdownMenuItem.value}]');
    // }

    return WitsOverflowScaffold(
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
                    this.questionTitle,
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
