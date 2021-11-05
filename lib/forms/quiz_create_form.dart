import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wits_overflow/screens/module_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// -----------------------------------------------------------------------------
//                      ANSWER EDIT FORM
// -----------------------------------------------------------------------------
class QuizCreateForm extends StatefulWidget {
  final TextStyle modalHeaderStyle = TextStyle(
    fontWeight: FontWeight.w600,
  );
  final String moduleId;

  final _firestore;
  final _auth;

  QuizCreateForm({required this.moduleId, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = firestore == null ? FirebaseAuth.instance : auth;

  @override
  _QuizCreateFormState createState() {
    return _QuizCreateFormState();
  }
}

enum QuestionType {
  TrueOrFalse,
  SingleAnswerMCQ,
  MultipleAnswersMCQ,
  NumberQuestion,
  SingleAnswerTypedQuestion
}

class _QuizCreateFormState extends State<QuizCreateForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController questionBodyController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();

  DateTime? _pickedDueDate;
  TimeOfDay? _pickedDueTime;
  List<Map<String, dynamic>> questions = [];

  WitsOverflowData witsOverflowData = WitsOverflowData();

  /// handler function when the user wants to add a question
  /// displays modal with types of questions the user can add to the quiz
  /// once the user chooses the question, the pop another modal with
  /// the associated form
  void _addQuestion(int questionNum) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        // Single number
        return SimpleDialog(
          title: Text('Question Type'),
          children: [
            SimpleDialogOption(
              child: const Text('Number Question'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text(
                        'Number Question',
                        style: this.widget.modalHeaderStyle,
                      ),
                      children: [
                        new NumberQuestionCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM NumberQuestionCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM NumberQuestionCreateForm $question]');
                    question.addAll({'type': QuestionType.NumberQuestion});
                    this.setState(() {
                      this
                          .questions
                          .insert(questionNum, question); //add(question);
                    });
                  }
                });
              },
            ),
            // Single Typed Answer
            SimpleDialogOption(
              child: const Text('Single Typed Answer Question'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text(
                        'Single Typed Answer Question',
                        style: this.widget.modalHeaderStyle,
                      ),
                      children: [
                        new SingleTypedAnswerQuestionCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM SingleTypedAnswerQuestionCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM SingleTypedAnswerQuestionCreateForm $question]');
                    question.addAll(
                        {'type': QuestionType.SingleAnswerTypedQuestion});
                    this.setState(() {
                      this
                          .questions
                          .insert(questionNum, question); //add(question);
                    });
                  }
                });
              },
            ),
            // True or false question
            SimpleDialogOption(
              child: Text(
                'True or False Question',
                style: this.widget.modalHeaderStyle,
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text('True or False Question'),
                      children: [
                        new TrueOrFalseQuestionCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM TrueOrFalseQuestionCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM TrueOrFalseQuestionCreateForm $question]');
                    question.addAll({'type': QuestionType.TrueOrFalse});
                    this.setState(() {
                      this.questions.insert(questionNum, question);
                    });
                  }
                });
              },
            ),
            // Single answer mcq
            SimpleDialogOption(
              child: Text(
                'Single Answer Multiple Choice Question',
                style: this.widget.modalHeaderStyle,
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  useSafeArea: true,
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text('Single Answer Multiple Choice Question'),
                      children: [
                        new SingleAnswerMCQCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM SingleAnswerMCQCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM SingleAnswerMCQCreateForm $question]');
                    question.addAll({'type': QuestionType.SingleAnswerMCQ});
                    this.setState(() {
                      this.questions.insert(questionNum, question);
                    });
                  }
                });
              },
            ),
            // MAQ
            SimpleDialogOption(
              child: Text(
                'Multiple Answers Multiple Choice Question',
                style: this.widget.modalHeaderStyle,
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text('Multiple Answers Multiple Choice Question'),
                      children: [
                        new MultipleAnswersMCQCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM MultipleAnswersMCQCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM MultipleAnswersMCQCreateForm $question]');
                    question.addAll({'type': QuestionType.MultipleAnswersMCQ});
                    this.setState(() {
                      this.questions.insert(questionNum, question);
                    });
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _publishQuiz() async {
    DateTime dueDateTime = DateTime(
      this._pickedDueDate!.year,
      this._pickedDueDate!.month,
      this._pickedDueDate!.day,
      this._pickedDueTime!.hour,
      this._pickedDueTime!.hour,
    );

    await this.widget._firestore.collection('quizzes').add({
      'dueDate': dueDateTime,
      'title': this.titleController.text,
      'createdAt': DateTime.now(),
      'author': this.widget._auth.currentUser!.uid,
      'moduleId': this.widget.moduleId,
    }).then((DocumentReference quiz) async {
      for (int i = 0; i < this.questions.length; i++) {
        Map<String, dynamic> question = this.questions[i];

        int number = i + 1;
        question['number'] = number;

        if (question['type'] == QuestionType.NumberQuestion) {
          question.update('type', (value) => 'NumberQuestion');
        } else if (question['type'] == QuestionType.SingleAnswerTypedQuestion) {
          question.update('type', (value) => 'SingleAnswerTypedQuestion');
        } else if (question['type'] == QuestionType.TrueOrFalse) {
          question.update('type', (value) => 'TrueOrFalse');
        } else if (question['type'] == QuestionType.SingleAnswerMCQ) {
          question.update('type', (value) => 'SingleAnswerMCQ');
        } else if (question['type'] == QuestionType.MultipleAnswersMCQ) {
          question.update('type', (value) => 'MultipleAnswersMCQ');
        }
        await quiz.collection('questions').add(question);
      }
    });

    showNotification(context, 'Successfully added quiz to database',
        type: 'success');
    await Future.delayed(Duration(seconds: 3));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return ModuleQuestionsScreen(moduleId: this.widget.moduleId);
      }),
    );
  }

  @override
  void initState() {
    witsOverflowData.initialize(
        firestore: this.widget._firestore, auth: this.widget._auth);
    super.initState();
  }

  Widget _buildQuestion(Map<String, dynamic> question) {
    List<Widget> children = [];

    children.add(
      Container(
        child: ListTile(
          title: Text(question['body']),
        ),
      ),
    );

    if (question['type'] == QuestionType.SingleAnswerMCQ) {
      question['choices'].forEach((String choice) {
        late ListTile choiceListTile;
        if (question['answer'] == choice) {
          choiceListTile = ListTile(
            title: RichText(
              text: TextSpan(
                text: '$choice ',
                style: TextStyle(color: Colors.blue),
                children: const <TextSpan>[
                  TextSpan(
                      text: '(correct answer)',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          );
        } else {
          choiceListTile = ListTile(
            title: Text(
              choice,
              // style: TextStyle(color: Colors.blue),
            ),
          );
        }
        children.add(
          choiceListTile,
        );
      });
    } else if (question['type'] == QuestionType.MultipleAnswersMCQ) {
      question['choices'].forEach((String choice) {
        late ListTile choiceListTile;
        if ((question['answers'] as List).contains(choice)) {
          choiceListTile = ListTile(
            title: RichText(
              text: TextSpan(
                text: '$choice ',
                style: TextStyle(color: Colors.blue),
                children: const <TextSpan>[
                  TextSpan(
                      text: '(correct answer)',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          );
        } else {
          choiceListTile = ListTile(
            title: Text(
              choice,
            ),
          );
        }
        children.add(
          choiceListTile,
        );
      });
    } else if (question['type'] == QuestionType.NumberQuestion) {
      children.add(
        Container(
            child: ListTile(
          title: RichText(
            text: TextSpan(
              text: '${question['answer']} ',
              style: TextStyle(color: Colors.blue),
              children: const <TextSpan>[
                TextSpan(
                    text: '(correct answer)',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                    )),
              ],
            ),
          ),
        )),
      );
    } else if (question['type'] == QuestionType.SingleAnswerTypedQuestion) {
      children.add(
        Container(
            child: ListTile(
          title: RichText(
            text: TextSpan(
              text: '${question['answer']} ',
              style: TextStyle(color: Colors.blue),
              children: const <TextSpan>[
                TextSpan(
                    text: '(correct answer)',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                    )),
              ],
            ),
          ),
        )),
      );
    } else if (question['type'] == QuestionType.TrueOrFalse) {
      late ListTile choiceListTile;
      List<bool> answers = [true, false];
      answers.forEach((answer) {
        if (question['answer'] == answer) {
          choiceListTile = ListTile(
            title: RichText(
              text: TextSpan(
                text: '${answer == true ? 'True' : 'False'} ',
                style: TextStyle(color: Colors.blue),
                children: const <TextSpan>[
                  TextSpan(
                      text: '(correct answer)',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                      )),
                ],
              ),
            ),
          );
        } else {
          choiceListTile = ListTile(
              title: Text(
            '${answer == true ? 'True' : 'False'}',
          ));
        }
        children.add(choiceListTile);
      });
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
      width: getContainerWidth(
          width: MediaQuery.of(context).size.width, maxWidth: 900),
      child: Column(
        children: children,
      ),
    );
  }

  Future<Null> _selectDateTime(BuildContext context) async {
    DateTime? date;
    TimeOfDay? time;
    date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030, 12, 23, 59, 59, 999999),
    );

    if (date != null) {
      time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        this.setState(() {
          this._pickedDueDate = date;
          this._pickedDueTime = time;
          this._dateTimeController.text =
              '${this._pickedDueDate!.year}-${this._pickedDueDate!.month}-${this._pickedDueDate!.day} ${this._pickedDueTime!.hour}:${this._pickedDueTime!.minute}';
        });
      }
    }
  }

  Widget _getQuestionsDivider(int position) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              height: 1,
              color: Colors.grey,
              alignment: Alignment.center,
              child: Divider(
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
              child: Row(
                children: [Icon(Icons.add), Text('Add question at $position')],
              ),
              onPressed: () {
                this._addQuestion(position);
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Container(
        margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Create quiz',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (this._formKey.currentState!.validate()) {
                  this._publishQuiz();
                }
              },
              child: Text('Publish quiz'),
            ),
          ],
        ),
      ),
      Container(
        width: getContainerWidth(width: MediaQuery.of(context).size.width),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // edit title
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: TextFormField(
                  key: Key('id_edit_quiz_title'),
                  controller: this.titleController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Give quiz title';
                    }
                    return null;
                  },
                ),
              ),

              // edit due date
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: InkWell(
                  onTap: () {
                    this._selectDateTime(context);
                  },
                  child: Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Due date & time',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Give quiz due date';
                        }
                        return null;
                      },
                      // text
                      enabled: false,
                      keyboardType: TextInputType.text,
                      controller: _dateTimeController,
                      //     contentPadding: EdgeInsets.all(5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    children.add(
      this._getQuestionsDivider(0),
    );

    for (int i = 0; i < this.questions.length; i++) {
      children.add(
        this._buildQuestion(this.questions[i]),
      );

      children.add(
        this._getQuestionsDivider(i + 1),
      );
    }

    return MaterialApp(
        home: WitsOverflowScaffold(
      auth: this.widget._auth,
      firestore: this.widget._firestore,
      body: Container(
        width: getContainerWidth(
            width: MediaQuery.of(context).size.width, maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          children: children,
        ),
      ),
    ));
  }
}

class SingleAnswerMCQCreateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SingleAnswerMCQCreateFormState();
  }
}

class _SingleAnswerMCQCreateFormState extends State<SingleAnswerMCQCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _choiceFormKey = GlobalKey<FormState>();
  Set<String> choices = {};
  TextEditingController questionBodyController = TextEditingController();
  TextEditingController editChoiceController = TextEditingController();
  late FocusNode editChoiceFocusNode;

  String? _answer;

  @override
  void dispose() {
    this.editChoiceFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this.editChoiceFocusNode = FocusNode();
  }

  void _addChoice() {
    this.setState(() {
      String choice = this.editChoiceController.text;
      this.choices.add(choice);
      if (this.choices.length == 1) {
        this._answer = choice;
      }
      this.editChoiceController.text = '';
    });
    this.editChoiceFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wChoices = [];

    this.choices.forEach((String choice) {
      late RadioListTile widget;
      late Widget title;

      if (choice == this._answer) {
        title = RichText(
          text: TextSpan(
              text: choice,
              style: TextStyle(color: Colors.blue),
              children: <TextSpan>[
                TextSpan(
                    text: ' (correct answer)',
                    style: TextStyle(color: Colors.blue, fontSize: 10))
              ]),
        );
      } else {
        title = Text(choice);
      }

      widget = RadioListTile<String>(
        title: title,
        value: choice,
        groupValue: this._answer,
        onChanged: (String? value) {
          if (value != null) {
            this.setState(() {
              this._answer = value;
            });
          }
        },
      );

      wChoices.add(
        widget,
      );
    });

    return Container(
      // constraints: BoxConstraints(minWidth: 100, maxWidth: ),
      padding: EdgeInsets.all(10),
      // alignment: AlignmentGeometry.,
      // width: MediaQuery.of(context).size.height * 90 / 100,
      width: getContainerWidth(width: MediaQuery.of(context).size.width),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        // a form to add a choice to a list of choices
        Container(
          alignment: Alignment.centerLeft,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                        child: ElevatedButton(
                      child: Text('Add Question'),
                      onPressed: () {
                        if (this._formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'type': QuestionType.SingleAnswerMCQ,
                            'body': this.questionBodyController.text,
                            'choices': this.choices.toList(),
                            'answer': this._answer,
                          });
                        }
                      },
                    ))
                  ],
                ),
              ),
              Container(
                child: Form(
                  key: this._formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        key: Key('id_edit_body'),
                        controller: this.questionBodyController,
                        minLines: 2,
                        maxLines: 10,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Question Body',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Give question body';
                          }
                          if (this.choices.length < 2) {
                            return 'Give at least two choice';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Form(
                  key: this._choiceFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        // onFieldSubmitted: (String choice){
                        //   this._addChoice();
                        // },
                        key: Key('id_edit_choice'),
                        minLines: 2,
                        maxLines: 10,

                        controller: this.editChoiceController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Choice',
                          helperText: '(Enter choice)',
                          helperStyle:
                              TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Give choice body';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.add), Text('Add choice')],
                      ),
                      onPressed: () {
                        // once this button is pressed, a question choice should be added
                        if (this._choiceFormKey.currentState!.validate()) {
                          this._addChoice();
                        }
                      }),
                ),
              ),
            ],
          ),
        ),

        this.choices.length > 0
            ? Container(
                // color: Colors.blue,
                alignment: Alignment.centerLeft,
                child: Text(
                  '(Click on the question to choose correct answer)',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ))
            : Padding(padding: EdgeInsets.all(0)),

        Container(
          child: Column(
            children: wChoices,
          ),
        ),
      ]),
    );
  }
}

class NumberQuestionCreateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NumberQuestionCreateFormState();
  }
}

class _NumberQuestionCreateFormState extends State<NumberQuestionCreateForm> {
  TextEditingController _answer = new TextEditingController();
  TextEditingController questionBodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        width: getContainerWidth(width: MediaQuery.of(context).size.width),
        child: Column(
          children: [
            Container(
              child: Form(
                key: this._formKey,
                child: Column(
                  children: [
                    TextFormField(
                      key: Key('id_edit_number_question_body'),
                      controller: this.questionBodyController,
                      maxLines: 15,
                      minLines: 10,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Question',
                        helperText:
                            '(Give question a body, add \'?\ at the end)',
                        helperStyle:
                            TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Give question body';
                        }
                        return null;
                      },
                    ),

                    Container(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Give correct answer';
                          }
                          return null;
                        },
                        controller: this._answer,
                        decoration: InputDecoration(
                          labelText: 'Correct value',
                          helperText: '(Give the correct number value)',
                          helperStyle:
                              TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),

                    /// submit button
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: ElevatedButton(
                        child: Text('Add Question'),
                        onPressed: () {
                          if (this._formKey.currentState!.validate()) {
                            Navigator.pop(context, {
                              'body': this.questionBodyController.text,
                              'answer': double.parse(this._answer.text),
                              'type': QuestionType.NumberQuestion,
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class SingleTypedAnswerQuestionCreateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SingleTypedAnswerCreateFormState();
  }
}

class _SingleTypedAnswerCreateFormState
    extends State<SingleTypedAnswerQuestionCreateForm> {
  TextEditingController _answer = new TextEditingController();
  TextEditingController questionBodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        width: getContainerWidth(width: MediaQuery.of(context).size.width),
        child: Column(
          children: [
            Container(
              child: Form(
                key: this._formKey,
                child: Column(
                  children: [
                    TextFormField(
                      key: Key('id_edit_typed answer_question_body'),
                      controller: this.questionBodyController,
                      maxLines: 15,
                      minLines: 10,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Question',
                        helperText:
                            '(Give question a body, add \'?\ at the end)',
                        helperStyle:
                            TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Give question body';
                        }
                        return null;
                      },
                    ),

                    Container(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Give correct answer';
                          }
                          return null;
                        },
                        controller: this._answer,
                        decoration: InputDecoration(
                          labelText: 'Correct value',
                          helperText:
                              '(Give the correct single typed answer value)',
                          helperStyle:
                              TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter
                        ],
                      ),
                    ),

                    /// submit button
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: ElevatedButton(
                        child: Text('Add Question'),
                        onPressed: () {
                          if (this._formKey.currentState!.validate()) {
                            Navigator.pop(context, {
                              'body': this.questionBodyController.text,
                              'answer': this._answer.text,
                              'type': QuestionType.NumberQuestion,
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class TrueOrFalseQuestionCreateForm extends StatefulWidget {
  // final List questions;
  // final position;

  // TrueOrFalseQuestionCreateForm({required this.position, required this.questions});

  @override
  State<StatefulWidget> createState() {
    return _TrueOrFalseQuestionCreateFormState();
  }
}

class _TrueOrFalseQuestionCreateFormState
    extends State<TrueOrFalseQuestionCreateForm> {
  final _formKey = GlobalKey<FormState>();
  bool _answer = true;
  TextEditingController questionBodyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        width: getContainerWidth(width: MediaQuery.of(context).size.width),
        child: Form(
          key: _formKey,
          // key: Key('id_true_or_false_question_create_form'),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            // Container(
            //   child: Text('True or False Question'),
            // ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose correct value',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RadioListTile<bool>(
                      title: const Text('True'),
                      value: true,
                      groupValue: this._answer,
                      onChanged: (bool? correct) {
                        if (correct != null) {
                          this.setState(() {
                            this._answer = true;
                          });
                        }
                      }),
                  RadioListTile<bool>(
                      title: const Text('False'),
                      value: false,
                      groupValue: this._answer,
                      onChanged: (bool? correct) {
                        if (correct != null) {
                          this.setState(() {
                            this._answer = false;
                          });
                        }
                      }),
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text('Question'),
            ),
            Container(
              child: TextFormField(
                key: Key('id_edit_true_or_false_question_body'),
                controller: this.questionBodyController,
                maxLines: 15,
                minLines: 10,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Question',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Give question body';
                  }
                  return null;
                },
              ),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      child: Text('Add Question'),
                      onPressed: () {
                        if (this._formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'body': this.questionBodyController.text,
                            'answer': this._answer,
                          });
                        }
                      }),
                ))
          ]),
        ));
  }
}

/// multiple choice with multiple answers
class MultipleAnswersMCQCreateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MultipleAnswersMCQCreateFormCreateFormState();
  }
}

/// I tried not to use checkboxes, instead I used the radio widget
class _MultipleAnswersMCQCreateFormCreateFormState
    extends State<MultipleAnswersMCQCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _choiceFormKey = GlobalKey<FormState>();
  TextEditingController questionBodyController = TextEditingController();
  TextEditingController editChoiceController = TextEditingController();
  Set<String> choices = {};
  List<bool> _answers = [];

  // controlling the text field
  late FocusNode editChoiceFocusNode;

  @override
  void initState() {
    super.initState();
    this.editChoiceFocusNode = FocusNode();
  }

  void _addChoice() {
    this.setState(() {
      String choice = this.editChoiceController.text;
      this.choices.add(choice);
      this._answers.add(false);
      this.editChoiceController.text = '';
    });

    this.editChoiceFocusNode.requestFocus();
  }

  @override
  void dispose() {
    this.editChoiceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wChoices = [];
    for (int i = 0; i < this.choices.length; i++) {
      late CheckboxListTile widget;
      late Widget title;

      // if the current choice is correct
      // add different styling to it
      if (this._answers.contains(choices.elementAt(i))) {
        title = RichText(
          text: TextSpan(
              text: choices.elementAt(i),
              style: TextStyle(color: Colors.blue),
              children: <TextSpan>[
                TextSpan(
                    text: ' (correct answer)',
                    style: TextStyle(color: Colors.blue, fontSize: 10))
              ]),
        );
      } else {
        title = Text(choices.elementAt(i));
      }

      widget = CheckboxListTile(
        title: title,
        value: this._answers[i],
        // groupValue: this._answers[i],
        onChanged: (bool? value) {
          this.setState(() {
            if (value != null) {
              this._answers[i] = value;
            }
          });
        },
      );

      wChoices.add(
        widget,
      );
    }

    return Container(
      padding: EdgeInsets.all(10),
      width: getContainerWidth(width: MediaQuery.of(context).size.width),
      child: Column(
        children: [
          Container(
            child: Form(
              key: this._formKey,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                // a form to add a choice to a list of choices

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                        child: ElevatedButton(
                      child: Text('Add Question'),
                      onPressed: () {
                        if (this._formKey.currentState!.validate()) {
                          List<String> answers = [];
                          for (int i = 0; i < this.choices.length; i++) {
                            if (this._answers[i] == true) {
                              answers.add(this.choices.elementAt(i));
                            }
                          }
                          Navigator.pop(context, {
                            'body': this.questionBodyController.text,
                            'type': QuestionType.MultipleAnswersMCQ,
                            'choices': this.choices.toList(),
                            'answers': answers,
                          });
                        } else {
                          showNotification(context, 'Invalid form data',
                              type: 'error');
                          print('[FORM VALIDATION -> ERROR]');
                        }
                      },
                    ))
                  ],
                ),

                TextFormField(
                  key: Key('id_edit_body'),
                  controller: this.questionBodyController,
                  minLines: 2,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Question Body',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Give question body';
                    }
                    if (this.choices.length < 2) {
                      return 'Give at least two choice';
                    }
                    if (!this._answers.contains(true)) {
                      return 'Choose at least one correct answer';
                    }
                    return null;
                  },
                ),
              ]),
            ),
          ),
          Container(
            child: Form(
              key: this._choiceFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: TextFormField(
                      key: Key('id_edit_choice'),
                      // onFieldSubmitted: (String choice){
                      //   this._addChoice();
                      // },
                      minLines: 2,
                      maxLines: 10,
                      controller: this.editChoiceController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Choice',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Give choice body';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                    alignment: Alignment.center,
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Icon(Icons.add), Text('Add choice')],
                          ),
                          onPressed: () {
                            // once this button is pressed, a question choice should be added
                            if (this._choiceFormKey.currentState!.validate()) {
                              this._addChoice();
                            }
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          this.choices.length > 0
              ? Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  alignment: Alignment.centerLeft,
                  child: Text('(Click/Tap to choose correct answers)',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      )))
              : Padding(padding: EdgeInsets.all(0)),
          Container(
            child: Column(
              children: wChoices,
            ),
          ),
        ],
      ),
    );
  }
}
