import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// -----------------------------------------------------------------------------
//                      ANSWER EDIT FORM
// -----------------------------------------------------------------------------
class QuizCreateForm extends StatefulWidget {
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
  MultipleChoiceSingleAnswer,
  MultipleChoiceMultipleAnswers,
  NumberQuestion
}

class _QuizCreateFormState extends State<QuizCreateForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController questionBodyController = TextEditingController();

  QuestionType? _questionType = QuestionType.TrueOrFalse;
  // bool _trueOrFalseCorrect = true;

  late ElevatedButton addQuestionBtn;

  // bool isBusy = true;
  // Map<String, dynamic>? question;
  List questions = [];

  WitsOverflowData witsOverflowData = WitsOverflowData();

  /// handler function when the user wants to add a question
  /// displays modal with types of questions the user can add to the quiz
  /// once the user chooses the question, the pop another modal with
  /// the associated form
  void _addQuestion(int questionNum) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
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
                      title: Text('Value'),
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
            SimpleDialogOption(
              child: const Text('True/False'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text('True or False'),
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
            SimpleDialogOption(
              child: const Text('Multiple Choice (Single)'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  useSafeArea: true,
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text('Multiple Choice (Single)'),
                      children: [
                        new MultipleChoiceQuestionCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM MultipleChoiceQuestionCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM MultipleChoiceQuestionCreateForm $question]');
                    question.addAll(
                        {'type': QuestionType.MultipleChoiceSingleAnswer});
                    this.setState(() {
                      this.questions.insert(questionNum, question);
                    });
                  }
                });
              },
            ),
            SimpleDialogOption(
              child: const Text('Multiple Choice (Multiple)'),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // show the true or false modal form
                    return SimpleDialog(
                      title: Text('Multiple Choice (Multiple)'),
                      children: [
                        new MultipleChoiceQuestionCreateForm(),
                      ],
                    );
                  },
                ).then((question) {
                  if (question == null) {
                    print(
                        '[RETURNED VALUE FROM MultipleChoiceQuestionCreateForm IS NULL]');
                  } else {
                    print(
                        '[RETURNED VALUE FROM MultipleChoiceQuestionCreateForm $question]');
                    question.addAll(
                        {'type': QuestionType.MultipleChoiceMultipleAnswers});
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

  // List<Widget> _buildQuestionWidgets(){
  //
  // }

  @override
  void initState() {
    witsOverflowData.initialize(
        firestore: this.widget._firestore, auth: this.widget._auth);
    super.initState();
  }

  Widget buildQuestion(Map<String, dynamic> question) {
    List<Widget> children = [];

    children.add(
      Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              child: Text('',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            ),
          ),
          Flexible(
            child: Container(
              child: ElevatedButton(
                child: Text('Publish quiz'),
                onPressed: () {
                  // TODO: add questions to the database
                },
              ),
            ),
          ),
        ],
      )),
    );
    children.add(
      Container(
        child: ListTile(
          title: Text(question['body']),
        ),
      ),
    );

    if (question['type'] == QuestionType.MultipleChoiceMultipleAnswers ||
        question['type'] == QuestionType.MultipleChoiceSingleAnswer) {
      question['choices'].forEach((String choice) {
        children.add(
          ListTile(
            title: Text(choice),
          ),
        );
      });
    } else if (question['type'] == QuestionType.NumberQuestion) {}

    return Container(
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Form(
        key: _formKey,
        child: Container(
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
      ),
    ];

    children.add(Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                this._addQuestion(0);
              }),
        ],
      ),
    ));

    for (int i = 0; i < this.questions.length; i++) {
      children.add(
        this.buildQuestion(this.questions[i]),
      );

      children.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            ),
            Flexible(
              child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    this._addQuestion(i + 1);
                  }),
            ),
          ],
        ),
      ));
    }

    return MaterialApp(
        home: WitsOverflowScaffold(
      auth: this.widget._auth,
      firestore: this.widget._firestore,
      body: ListView(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        children: children,
      ),
    ));
  }
}

class MultipleChoiceQuestionCreateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MultipleChoiceQuestionCreateFormState();
  }
}

class _MultipleChoiceQuestionCreateFormState
    extends State<MultipleChoiceQuestionCreateForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> choices = [];
  TextEditingController questionBodyController = TextEditingController();

  // controlling the text field
  TextEditingController editChoiceController = TextEditingController();

  String? _answer;

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
      height: MediaQuery.of(context).size.height * 90 / 100,
      width: getContainerWidth(width: MediaQuery.of(context).size.width),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        // Container(
        //   child: Text('Multiple Choice Question'),
        // ),

        // a form to add a choice to a list of choices
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Flexible(
                    //   child: Text(
                    //     'Question Body'
                    //   )
                    // ),
                    Flexible(
                        child: ElevatedButton(
                      child: Text('Add Question'),
                      onPressed: () {
                        Navigator.pop(context, {
                          'type': QuestionType.MultipleChoiceSingleAnswer,
                          'choices': [],
                          'answer': this._answer,
                        });
                      },
                    ))
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                        child: Text('', style: TextStyle(color: Colors.grey))),
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
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: Text('Add choice'),
                    ),
                    Container(
                      child: TextFormField(
                        key: Key('id_edit_choice'),
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
                  ],
                ),
              ),
              Container(
                child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      // TODO: implementation missing here
                      // once this button is pressed, a question choice should be added
                      this.setState(() {
                        String choice = this.editChoiceController.text;
                        this.choices.add(choice);
                        if (this.choices.length == 1) {
                          this._answer = choice;
                        }
                        this.editChoiceController.text = '';
                      });
                    }),
              ),
            ],
          ),
        ),

        this.choices.length > 0
            ? Container(
                child: Text('(Click on the question to choose correct answer)',
                    style: TextStyle(color: Colors.grey)))
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
  double? _answer;
  TextEditingController questionBodyController = TextEditingController();

  Widget build(BuildContext context) {
    return Container(
        width: getContainerWidth(width: MediaQuery.of(context).size.width),
        child: Column(
          children: [
            Container(
              child: Form(
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
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Correct value',
                          helperText:
                              '(This is the helper from TextField.decoration)',
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
                      child: ElevatedButton(
                        child: Text('Submit'),
                        onPressed: () {
                          Navigator.pop(context, {
                            'body': this.questionBodyController.text,
                            'answer': this._answer,
                            'type': QuestionType.NumberQuestion,
                          });
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
        width: getContainerWidth(width: MediaQuery.of(context).size.width),
        child: Form(
          key: _formKey,
          // key: Key('id_true_or_false_question_create_form'),
          child: Column(children: [
            Container(
              child: Text('True or False Question'),
            ),
            Container(
              child: Text('Choose correct value'),
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
                        print('[TRUE OR FALSE ON_CHANGE -> $correct]');
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
                        print('[TRUE OR FALSE ON_CHANGE -> $correct]');
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
                child: ElevatedButton(
                    child: Text('Submit'),
                    onPressed: () {
                      // TODO: add question to the questions list
                      Navigator.pop(context, {
                        'body': this.questionBodyController.text,
                        'answer': this._answer,
                        'choices': ['True', 'False'],
                      });
                    }))
          ]),
        ));
  }
}

/// multiple choice with multiple answers
class MultipleChoiceMAQuestionCreateForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MultipleChoiceMAQuestionCreateFormState();
  }
}

/// I tried not to use checkboxes, instead I used the radio widget
class _MultipleChoiceMAQuestionCreateFormState
    extends State<MultipleChoiceMAQuestionCreateForm> {
  final _formKey = GlobalKey<FormState>();
  List<String> choices = [];
  TextEditingController questionBodyController = TextEditingController();

  // controlling the text field
  TextEditingController editChoiceController = TextEditingController();

  // if choices at i is correct on the the coreect answers
  // then _answers[i] = true, else false
  List<bool> _answers = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> wChoices = [];

    for (int i = 0; i < this.choices.length; i++) {
      late CheckboxListTile widget;
      late Widget title;

      // if the current choice is correct
      // add different styling to it
      if (this._answers.contains(choices[i])) {
        title = RichText(
          text: TextSpan(
              text: choices[i],
              style: TextStyle(color: Colors.blue),
              children: <TextSpan>[
                TextSpan(
                    text: ' (correct answer)',
                    style: TextStyle(color: Colors.blue, fontSize: 10))
              ]),
        );
      } else {
        title = Text(choices[i]);
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
            // else{
            //   this._answers[i] = '_' + this.choices[i];
            // }
          });
        },
      );

      wChoices.add(
        widget,
      );
    }
    ;

    return Container(
      // constraints: BoxConstraints(minWidth: 100, maxWidth: ),
      padding: EdgeInsets.all(10),
      // alignment: AlignmentGeometry.,
      height: MediaQuery.of(context).size.height * 90 / 100,
      width: getContainerWidth(width: MediaQuery.of(context).size.width),
      child: Form(
        key: this._formKey,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // a form to add a choice to a list of choices
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                          child: ElevatedButton(
                        child: Text('Add Question'),
                        onPressed: () {
                          Navigator.pop(context, {
                            'type': QuestionType.MultipleChoiceSingleAnswer,
                            'choices': [],
                            'answers': this._answers,
                          });
                        },
                      ))
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                          child:
                              Text('', style: TextStyle(color: Colors.grey))),
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
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Text('Add choice'),
                      ),
                      Container(
                        child: TextFormField(
                          key: Key('id_edit_choice'),
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
                    ],
                  ),
                ),
                Container(
                  child: TextButton(
                      child: Container(child: Text('Submit')),
                      // icon: Icon(Icons.add),
                      onPressed: () {
                        // TODO: implementation missing here
                        // once this button is pressed, a question choice should be added
                        this.setState(() {
                          String choice = this.editChoiceController.text;
                          this.choices.add(choice);
                          this._answers.add(false);
                          // int length = this.choices.length;
                          // if(length == 1){
                          //   this._answers[length - 1] = choice;
                          // }
                          this.editChoiceController.text = '';
                        });
                      }),
                ),
              ],
            ),
          ),

          this.choices.length > 0
              ? Container(
                  child: Text(
                      '(Click on the question to choose correct answer)',
                      style: TextStyle(color: Colors.grey)))
              : Padding(padding: EdgeInsets.all(0)),

          Container(
            child: Column(
              children: wChoices,
            ),
          ),
        ]),
      ),
    );
  }
}
