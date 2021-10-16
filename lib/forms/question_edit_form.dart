import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

class QuestionEditForm extends StatefulWidget {
  late final _firestore;
  late final _auth;
  final String questionId;

  QuestionEditForm({required this.questionId, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionEditFormState createState() => _QuestionEditFormState();
}

class _QuestionEditFormState extends State<QuestionEditForm> {
  final titleController = new TextEditingController();
  final bodyController = new TextEditingController();

  late final Map<String, dynamic> question;

  WitsOverflowData witsOverflowData = WitsOverflowData();

  Future<void> getData() async {
    this.question =
        (await this.witsOverflowData.fetchQuestion(this.widget.questionId))!;
    this.titleController.text = this.question['title'];
    this.bodyController.text = this.question['body'];
  }

  @override
  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  Future<void> _editQuestion() async {
    this
        .widget
        ._firestore
        .collection(COLLECTIONS['questions'])
        .doc(this.widget.questionId)
        .update({
      'title': this.titleController.text,
      'body': this.bodyController.text,
    }).then((value) {
      showNotification(this.context, 'Successfully updated question',
          type: 'success');
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (BuildContext context) {
          return QuestionAndAnswersScreen(
            this.widget.questionId,
            firestore: this.widget._firestore,
            auth: this.widget._auth,
          );
        }),
      );
    }, onError: (error) {
      showNotification(this.context, 'Error occurred', type: 'error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return WitsOverflowScaffold(
        auth: this.widget._auth,
        firestore: this.widget._firestore,
        body: Container(
            padding: EdgeInsets.all(10),
            child: Form(
                child: ListView(
              children: [
                TextFormField(
                  key: Key('id_edit_title'),
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: 'Title',
                      alignLabelWithHint: true,
                      hintText: 'e.g. Is there a python function for...',
                      border: OutlineInputBorder()),
                ),
                Divider(color: Colors.white, height: 10),
                TextFormField(
                  key: Key('id_edit_body'),
                  controller: bodyController,
                  maxLines: 10,
                  decoration: InputDecoration(
                      labelText: 'Question',
                      alignLabelWithHint: true,
                      hintText: 'Include as much information as possible...',
                      border: OutlineInputBorder()),
                ),
                Divider(color: Colors.white, height: 10),
                Container(
                  child: ElevatedButton.icon(
                    key: Key('id_submit'),
                    onPressed: () => {this._editQuestion()},
                    icon: Icon(Icons.post_add),
                    label: Text('Submit'),
                  ),
                )
              ],
            ))));
  }
}
