import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AnswerQuizForm extends StatefulWidget {
  late final _firestore;
  late final _auth;
  final String quizId;

  AnswerQuizForm({required this.quizId, firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  State<StatefulWidget> createState() {
    return _AnswerQuizForm();
  }
}

class _AnswerQuizForm extends State<AnswerQuizForm> {
  bool _loading = true;
  late Map<String, dynamic> quiz;
  late List<Map<String, dynamic>> questions = [];
  late List<dynamic> _answers = [];
  Map<int, TextEditingController> _editors = {};

  void getData() async {
    // print('[ANSWER QUIZ FORM GET DATA]');
    DocumentReference<Map<String, dynamic>> quizRef =
        this.widget._firestore.collection('quizzes').doc(this.widget.quizId);

    await quizRef.get().then((q) {
      Map<String, dynamic>? data = q.data();
      if (data != null) {
        this.quiz = data;
        this.quiz.addAll({'id': q.id});
      }
    });

    await quizRef.collection('questions').get().then((snapshot) {
      // Map<String, dynamic> q =
      snapshot.docs.forEach((question) {
        Map<String, dynamic> q = question.data();
        q.addAll({'id': question.id});
        this.questions.add(q);
      });

      // initialize answers and text editing controllers
      this._answers = [];
      for (int i = 0; i < this.questions.length; i++) {
        if (this.questions[i]['type'] == 'TrueOrFalse') {
          this._answers.add(null);
        } else if (this.questions[i]['type'] == 'NumberQuestion') {
          this._answers.add(null);
          this._editors.addAll({1: TextEditingController()});
        } else if (this.questions[i]['type'] == 'SingleAnswerTypedQuestion') {
          this._answers.add(null);
          this._editors.addAll({1: TextEditingController()});
        } else if (this.questions[i]['type'] == 'SingleAnswerMCQ') {
          this._answers.add(null);
        } else {
          List<bool> a = [];
          for (int j = 0; j < this.questions[i]['choices'].length; j++) {
            a.add(false);
          }
          this._answers.add(a);
        }
      }
    });

    this.setState(() {
      this._loading = false;
    });
  }

  // Widget buildQuestion(Map<String,>)

  void initState() {
    // print('2 -> [ANSWER QUIZ FORM ->RETURNING WITS OVERFLOW]');
    /*

		TrueOrFalse,
		SingleAnswerMCQ,
		MultipleAnswersMCQ,
		NumberQuestion
		 */
    super.initState();
    this.getData();
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question, index) {
    if (question['type'] == 'NumberQuestion') {
      Widget widget = Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 0.5, color: Colors.grey),
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1} ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('${question['body']}'),
                  ],
                ),
              ),
              TextFormField(
                key: Key('id_edit_body'),
                controller: this._editors[index],
                // minLines: 2,
                // maxLines: 10,
                decoration: InputDecoration(
                  // border: BoxBorder.all(color: Colors.grey, width: 0.5),
                  labelText: '',
                  helperText: '(Enter your answer above)',
                  helperStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return 'Give question body';
                  // }
                  // if (this.choices.length < 2) {
                  //   return 'Give at least two choice';
                  // }
                  // if (!this._answers.contains(true)) {
                  //   return 'Choose at least one correct answer';
                  // }
                  // return null;
                },
                onChanged: (text) {
                  this._answers[index] = text;
                },
              ),
            ],
          ));

      return widget;
    } else if (question['type'] == 'SingleAnswerTypedQuestion') {
      Widget widget = Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 0.5, color: Colors.grey),
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1} ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text('${question['body']}'),
                  ],
                ),
              ),
              TextFormField(
                key: Key('id_edit_body2'),
                controller: this._editors[index],
                // minLines: 2,
                // maxLines: 10,
                decoration: InputDecoration(
                  // border: BoxBorder.all(color: Colors.grey, width: 0.5),
                  labelText: '',
                  helperText: '(Enter your answer above)',
                  helperStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
                validator: (value) {
                  // if (value == null || value.isEmpty) {
                  //   return 'Give question body';
                  // }
                  // if (this.choices.length < 2) {
                  //   return 'Give at least two choice';
                  // }
                  // if (!this._answers.contains(true)) {
                  //   return 'Choose at least one correct answer';
                  // }
                  // return null;
                },
                onChanged: (text) {
                  this._answers[index] = text;
                },
              ),
            ],
          ));

      return widget;
    } else if (question['type'] == 'TrueOrFalse') {
      // print('[BUILDING TRUE OR FALSE QUESTION]');
      return Flexible(
        child: Container(
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 0.5, color: Colors.grey),
          ),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          child: Text('${index + 1}. ',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            question['body'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    child: Column(
                  children: [
                    RadioListTile<bool>(
                      title: Text('True'),
                      value: true,
                      groupValue: this._answers[index],
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            this._answers[index] = true;
                          });
                        }
                      },
                    ),
                    RadioListTile<bool>(
                      title: Text('False'),
                      value: false,
                      groupValue: this._answers[index],
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            this._answers[index] = false;
                          });
                        }
                      },
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      );
    } else if (question['type'] == 'SingleAnswerMCQ') {
      // print('[BEFORE CAST]');
      List<String> choices = [];
      // List<String> choices = (question['choices'] as List<String>);
      for (int i = 0; i < question['choices'].length; i++) {
        choices.add(question['choices'][i] as String);
      }
      // print('[AFTER CAST]');

      // (question['choices'] as List<String>);
      List<Widget> wChoices = [];

      for (int i = 0; i < choices.length; i++) {
        wChoices.add(
          RadioListTile<String>(
              value: choices[i],
              title: Text(choices[i]),
              groupValue: this._answers[index],
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    this._answers[index] = value;
                  });
                }
              }),
        );
      }

      Widget widget = Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(width: 0.5, color: Colors.grey),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('${question['body']}'),
                ],
              ),
            ),
            Container(
              child: Column(children: wChoices),
            ),
          ],
        ),
      );

      return widget;
    } else if (question['type'] == 'MultipleAnswersMCQ') {
      List<String?> choices = [];
      for (int i = 0; i < question['choices'].length; i++) {
        choices.add(question['choices'][i] as String);
      }

      List<Widget> wChoices = [];

      wChoices.add(
        MultiSelectDialogField(
          items: choices.map((e) => MultiSelectItem(e, e!)).toList(),
          listType: MultiSelectListType.CHIP,
          onConfirm: (values) {
            setState(() {
              this._answers[index] = values;
            });
          },
        ),
      );

      Widget widget = Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(width: 0.5, color: Colors.grey),
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1} ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('${question['body']}'),
                ],
              ),
            ),
            Container(
              child: Column(children: wChoices),
            ),
          ],
        ),
      );

      return widget;
    } else {
      return Padding(padding: EdgeInsets.all(50));
    }
  }

  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // print('1 -> [ANSWER QUIZ FORM -> RETURNING WITS OVERFLOW]');
    List<Widget> children = [];
    for (int i = 0; i < this.questions.length; i++) {
      children.add(
        this._buildQuestionWidget(this.questions[i], i),

        // Container(
        //   child: Column(
        //     children: [
        //       Container(
        //         // question body
        //
        //         // child: Text(this.questions[i]['body']),
        //       ),
        //       // Container(),
        //     ],
        //   ),
        // ),
      );
    }
    children.add(TextButton(
        onPressed: () {
          postAnswer();
          Navigator.of(context).pop();
        },
        child: Text("Submit")));
    // print('2 -> [ANSWER QUIZ FORM ->RETURNING WITS OVERFLOW]');

    return WitsOverflowScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  void postAnswer() async {
    // for (int i = 0; i < this._answers.length; i++) {
    //   print(this._answers[i].toString());
    // }
    DocumentReference<Map<String, dynamic>> quizRef =
        this.widget._firestore.collection('quizzes').doc(this.widget.quizId);
    Map<String, dynamic> finalAnswers = {};

    finalAnswers['author'] = this.widget._auth.currentUser!.uid;

    for (int i = 0; i < this._answers.length; i++) {
      finalAnswers[i.toString()] = this._answers[i].toString();
    }

    await quizRef.collection('answeredQuizzes').add(finalAnswers);
  }
}
