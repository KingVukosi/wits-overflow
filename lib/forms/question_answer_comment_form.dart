import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/DataModel.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/DroppedFileWidget.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

import 'package:universal_html/html.dart' as uhtml;
import 'package:firebase/firebase.dart' as fb;

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM
// -----------------------------------------------------------------------------
class QuestionAnswerCommentForm extends StatefulWidget {
  final String questionId;
  final String answerId;

  final _firestore;
  final _auth;

  QuestionAnswerCommentForm(
      {required this.questionId, required this.answerId, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionAnswerCommentFormState createState() {
    return _QuestionAnswerCommentFormState();
  }
}

// -----------------------------------------------------------------------------
//                      QUESTION CREATE FORM STATE
// -----------------------------------------------------------------------------
class _QuestionAnswerCommentFormState extends State<QuestionAnswerCommentForm> {
  final _formKey = GlobalKey<FormState>();
  // final String questionId;

  bool isBusy = true;
  late final Map<String, dynamic>? question;
  late final Map<String, dynamic>? answer;

  late DropzoneViewController controller;

  DataModel? droppedFile;

  bool highlight = false;

  uhtml.File? file;

  String? imageURL;

  final bodyController = TextEditingController();

  WitsOverflowData witsOverflowData = WitsOverflowData();

  @override
  void initState() {
    super.initState();

    witsOverflowData.initialize(
        firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();
  }

  void getData() async {
    this.question =
        await witsOverflowData.fetchQuestion(this.widget.questionId);
    this.answer = await witsOverflowData.fetchAnswer(
        questionId: this.widget.questionId, answerId: this.widget.answerId);

    setState(() {
      this.isBusy = false;
    });
  }

  void submitComment(String body) async {
    setState(() {
      isBusy = true;
    });

    String authorId = witsOverflowData.getCurrentUser()!.uid;
    Map<String, dynamic>? questionComment =
        await witsOverflowData.postQuestionAnswerComment(
            questionId: this.widget.questionId,
            answerId: this.widget.answerId,
            body: body,
            image: imageURL!,
            authorId: authorId);

    if (questionComment == null) {
      showNotification(this.context, 'Something went wrong', type: 'error');
    } else {
      showNotification(this.context, 'Successfully posted your comment');

      // wait three seconds and navigate to the question and answers screen
      await Future.delayed(Duration(seconds: 4)).then((value) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return QuestionAndAnswersScreen(
              this.widget.questionId,
              firestore: this.widget._firestore,
              auth: this.widget._auth,
            );
          },
        ));
      });
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

          // show answer information
          Container(
            child: Text(
              this.answer?['body'],
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
                        key: Key('id_comment_body'),
                        controller: this.bodyController,
                        maxLines: 15,
                        minLines: 10,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'comment',
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
                      // color:Color.fromARGB(1000, 100, 100, 100),
                      // alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: ElevatedButton(
                        key: Key('id_submit_comment'),
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
      this.submitComment(bodyController.text.toString());
      print(imageURL);
    } else {
      imageURL = 'NULL';
      this.submitComment(bodyController.text.toString());
      // print(imageURL);
    }
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
}
