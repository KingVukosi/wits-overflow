import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final _firestore;
  final _auth;

  QuestionAnswerForm({required this.questionId, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionAnswerFormState createState() {
    return _QuestionAnswerFormState();
  }
}

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM STATE
// -----------------------------------------------------------------------------
class _QuestionAnswerFormState extends State<QuestionAnswerForm> {
  final _formKey = GlobalKey<FormState>();

  bool isBusy = true;
  late Map<String, dynamic> question;

  final bodyController = TextEditingController();

  WitsOverflowData witsOverflowData = WitsOverflowData();

  XFile? _image; // Used only if you need a single picture
  Uint8List? imageForSendToAPI;

  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  Future getImage(bool gallery) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageForSendToAPI = await image.readAsBytes();
    }
    setState(() {
      if (image != null) {
        _image = image;
      } else {
        print('No image selected.');
      }
    });
  }

  void getData() async {
    this.question =
        (await witsOverflowData.fetchQuestion(this.widget.questionId))!;

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
          questionId: this.widget.questionId,
          authorId: authorId,
          body: body,
          image: this._image);

      if (answer == null) {
        showNotification(this.context, 'Something went wrong', type: 'error');
      } else {
        showNotification(this.context, 'Successfully posted your answer');

        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return QuestionAndAnswersScreen(this.widget.questionId);
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
    late Widget imageView;

    if (this._image != null) {
      print('[BUILDING -> image is not none, path = ${this._image!.path}]');

      imageView = Container(
        height: 260,
        width: 260,
        child: Image.memory(this.imageForSendToAPI!),
      );
    } else {
      imageView = Container(
        child: Padding(padding: EdgeInsets.all(10)),
      );
    }

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
                    this.question['title'],
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
                    this.question['body'],
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
                        key: Key('id_edit_answer_body'),
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
                    Divider(color: Colors.white, height: 10),
                    RawMaterialButton(
                      fillColor: Theme.of(context).hintColor,
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                      ),
                      elevation: 8,
                      onPressed: () {
                        getImage(true);
                      },
                      padding: EdgeInsets.all(15),
                      shape: CircleBorder(),
                    ),
                    Divider(color: Colors.white, height: 10),
                    imageView,
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: ElevatedButton(
                        key: Key('id_submit'),
                        onPressed: () {
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
