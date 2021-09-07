import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// -----------------------------------------------------------------------------
//                      ANSWER EDIT FORM
// -----------------------------------------------------------------------------
class AnswerEditForm extends StatefulWidget {
  final String questionId;
  final String answerId;
  final String body;

  final _firestore;
  final _auth;

  AnswerEditForm({required this.questionId, required this.answerId, required this.body, firestore, auth}) :
        this._firestore = firestore == null ? FirebaseFirestore.instance: firestore,
        this._auth = firestore == null ? FirebaseAuth.instance: firestore;

  @override
  _AnswerEditFormState createState() {
    return _AnswerEditFormState(this.questionId, answerId, this.body, firestore: this._firestore, auth: this._auth);
  }
}


class _AnswerEditFormState extends State<AnswerEditForm> {
  final _formKey = GlobalKey<FormState>();
  final String questionId;
  final String answerId;
  final String body;
  // String? _body;

  bool isBusy = true;
  Map<String, dynamic> ? question;

  late TextEditingController bodyController;

  WitsOverflowData witsOverflowData = WitsOverflowData();
  late var _firestore;
  late var _auth;

  _AnswerEditFormState(this.questionId, this.answerId, this.body, {firestore, auth}){
    this._firestore = firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);

    this.bodyController = TextEditingController(text: this.body);

    this.getData();
  }

  void getData() async{
    this.question = await witsOverflowData.fetchQuestion(questionId);

    setState(() {
      this.isBusy = false;
    });
  }


  void submitAnswer(String body) async{

    setState(() {
      isBusy = true;
    });

    String editorId = witsOverflowData.getCurrentUser()!.uid;
    Map<String, dynamic>? editedAnswer = await witsOverflowData.editAnswer(questionId: this.questionId, answerId: this.answerId, body: body, editorId: editorId,editedAt: DateTime.now());

    if(editedAnswer == null){
      showNotification(this.context, 'Something went wrong', type: 'error');
    }
    else{
      showNotification(this.context, 'Successful');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context){
            return QuestionAndAnswersScreen(this.questionId);
          },
        )
      );
    }

    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.isBusy) {
      return WitsOverflowScaffold(
        auth: this._auth,
        firestore: this._firestore,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WitsOverflowScaffold(
      auth: this._auth,
      firestore: this._firestore,
      body: ListView(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
            color: Color.fromARGB(100, 220, 220, 220),
            child:Text(
              'Question',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(100, 16, 16, 16)
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  // color: Colors.black12,
                  // decoration: BoxDecoration(
                  //   border: Border(
                  //     bottom: BorderSide(
                  //       color: Colors.black12,
                  //       width: 0.5,
                  //     ),
                  //   ),
                  // ),
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    toTitleCase(this.question?['title']),
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
            child:Text(
              'Edit answer',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(100, 16, 16, 16)
              ),
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
                          labelText: 'Answer',

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
                        onPressed: (){
                          this.submitAnswer(bodyController.text.toString());
                        },
                        child: Text('Sumbit'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],),
    );
  }
}
