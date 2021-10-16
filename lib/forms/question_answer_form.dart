import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/DataModel.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/DroppedFileWidget.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import 'package:wits_overflow/utils/exceptions.dart';

import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:universal_html/html.dart' as uhtml;
import 'package:firebase/firebase.dart' as fb;

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
  late DropzoneViewController controller;

  DataModel? droppedFile;

  bool highlight = false;

  uhtml.File? file;

  String? imageURL;
  final _formKey = GlobalKey<FormState>();

  bool isBusy = true;
  late Map<String, dynamic> question;

  final bodyController = TextEditingController();

  WitsOverflowData witsOverflowData = WitsOverflowData();

  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
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
          image: imageURL!);

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
                    // Image Drop Section
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 160,
                              padding: EdgeInsets.all(10),
                              color:
                                  highlight == true ? Colors.grey : Colors.blue,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                                child: Stack(
                                  children: [
                                    DropzoneView(
                                        onDrop: uploadedFile,
                                        onCreated: (dropController) =>
                                            this.controller = dropController,
                                        onHover: () {
                                          setState(() {
                                            highlight = true;
                                          });
                                        },
                                        onLeave: () {
                                          setState(() {
                                            highlight = false;
                                          });
                                        }),
                                    Center(
                                      child: Column(children: [
                                        SizedBox(height: 10),
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                        Text("Drop image here"),
                                        SizedBox(height: 14),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final events =
                                                await controller.pickFiles();
                                            if (events.isEmpty) return;
                                            uploadedFile(events.first);
                                          },
                                          icon: Icon(Icons.search),
                                          label: Text("Choose an image"),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            primary: Colors.blue[300],
                                            shape: RoundedRectangleBorder(),
                                          ),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: // Dropped Image
                              ClipRRect(
                            child: Container(
                              alignment: Alignment.center,
                              // padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  DroppedFileWidget(droppedFile: droppedFile),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: ElevatedButton(
                        key: Key('id_submit'),
                        onPressed: () {
                          makePost();
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

  makePost() async {
    if (file != null) {
      await uploadImage(file!, imageName: 'images/${DateTime.now()}');
      this.submitAnswer(this.bodyController.text.toString());
      print(imageURL);
    } else {
      imageURL = 'NULL';
      this.submitAnswer(this.bodyController.text.toString());
      // print(imageURL);
    }
  }

  // To create file from user selected image
  Future uploadedFile(dynamic events) async {
    final name = events.name;
    final mime = await controller.getFileMIME(events);
    final byte = await controller.getFileSize(events);
    final url = await controller.createFileUrl(events);

    setState(() {
      droppedFile = DataModel(name: name, mime: mime, bytes: byte, url: url);
      highlight = false;
      file = events;
    });
  }

  // Function to upload image to firebase storage
  Future uploadImage(uhtml.File image, {required String imageName}) async {
    try {
      //Upload Profile Photo
      fb.StorageReference _storage = fb
          .storage()
          .refFromURL('gs://wits-overflow-2021.appspot.com')
          .child(imageName);
      fb.UploadTaskSnapshot uploadTaskSnapshot =
          await _storage.put(image).future;
      // Wait until the file is uploaded then store the download url
      var imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
      setState(() {
        imageURL = imageUri.toString();
      });
      // print(URL);
    } catch (e) {
      print(e);
    }
  }
}
