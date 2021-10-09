import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/DataModel.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/DroppedFileWidget.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:universal_html/html.dart' as uhtml;
import 'package:firebase/firebase.dart' as fb;
import 'dart:html' as html;

class PostQuestionScreen extends StatefulWidget {
  // late WitsOverflowData witsOverflowData;// = WitsOverflowData();
  late final _firestore;
  late final _auth;

  PostQuestionScreen({firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth {
    // this._firestore = firestore == null ? FirebaseFirestore.instance : firestore;
    // this._auth = auth == null ? FirebaseAuth.instance : auth;
    // witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
    // coursesFuture = witsOverflowData.fetchCourses();
  }

  @override
  _PostQuestionScreenState createState() =>
      _PostQuestionScreenState(firestore: this._firestore, auth: this._auth);
}

class _PostQuestionScreenState extends State<PostQuestionScreen> {
  late DropzoneViewController controller;

  DataModel? droppedFile;

  bool highlight = false;

  uhtml.File? file;

  String? URL;

  late final Future<List<Map<String, dynamic>>> coursesFuture;

  late List<Map<String, dynamic>>? _courses;
  late List<Map<String, dynamic>>? _modules;

  late Future<List<Map<String, dynamic>>> modulesFuture;

  String? _selectedCourseId;
  String? _selectedCourseCode;
  String? _selectedModuleId;
  String? _selectedModuleCode;

  final titleController = new TextEditingController();
  final bodyController = new TextEditingController();

  WitsOverflowData witsOverflowData = new WitsOverflowData();
  late final _auth;
  var _firestore;

  _PostQuestionScreenState({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
  }

  void _notify(message) {
    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.CENTER,
    //   timeInSecForIosWeb: 1
    // );

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.green,
        ),
      ),
      // backgroundColor: Colors.greenAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _validQuestion() {
    bool valid = true;

    if (_selectedCourseId == null || _selectedCourseId == "") {
      valid = false;
      _notify('Please select a course.');
    }

    if (_selectedModuleId == null || _selectedModuleId == "") {
      valid = false;
      _notify('Please select a module.');
    }

    if (titleController.text == "") {
      valid = false;
      _notify('Please supply a title.');
    }

    if (bodyController.text == "") {
      valid = false;
      _notify('Please supply details for your question.');
    }

    return valid;
  }

  void _addQuestion() {
    if (_validQuestion()) {
      witsOverflowData.addQuestion({
        'createdAt': DateTime.now(),
        'courseId': _selectedCourseId,
        'moduleId': _selectedModuleId,
        'title': titleController.text,
        'image': URL,
        'body': bodyController.text,
        'authorId': witsOverflowData.getCurrentUser()!.uid,
        'tags': [_selectedCourseCode, _selectedModuleCode]
      }).then((DocumentReference<Map<String, dynamic>> question) {
        _notify('Question added.');
        Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) {
            return QuestionAndAnswersScreen(question.id);
          },
        ));
      }).catchError((error) {
        _notify("Error occurred");
      });
    }
  }

  void _selectCourse(String? courseId) {
    this._selectedCourseId = courseId;
    this._courses!.forEach((course) {
      if (course['id'] == courseId) {
        this._selectedCourseCode = course['code'];
      }
    });

    setState(() {});
  }

  void _selectModule(String? moduleId) {
    this._selectedModuleId = moduleId;
    this._modules!.forEach((module) {
      if (module['id'] == moduleId) {
        this._selectedModuleCode = module['code'];
      }
    });

    setState(() {});
  }

  @override
  void setState(fn) {
    modulesFuture = witsOverflowData.fetchModules(this._selectedCourseId);
    super.setState(fn);
  }

  @override
  void initState() {
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
    modulesFuture = witsOverflowData.fetchModules(this._selectedCourseId);
    coursesFuture = witsOverflowData.fetchCourses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WitsOverflowScaffold(
        auth: this._auth,
        firestore: this._firestore,
        body: Container(
            padding: EdgeInsets.all(10),
            child: Form(
                child: ListView(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: this.coursesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      if (snapshot.hasData) {
                        this._courses = snapshot.data;

                        return DropdownButtonFormField<String?>(
                          onChanged: (String? courseId) {
                            setState(() {
                              _selectCourse(courseId);
                            });
                          },
                          items: snapshot.data!.map((course) {
                            return DropdownMenuItem<String?>(
                                value: course['id'],
                                child: Text(course['name']));
                          }).toList(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        );
                      } else {
                        return Text('Please load courses');
                      }
                    }),
                Divider(color: Colors.white, height: 10),
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: modulesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }

                      if (snapshot.hasData) {
                        this._modules = snapshot.data;

                        return DropdownButtonFormField<String?>(
                          onChanged: (String? moduleId) {
                            setState(() {
                              _selectModule(moduleId);
                            });
                          },
                          items: snapshot.data!.map((module) {
                            return DropdownMenuItem<String?>(
                                value: module['id'],
                                child: Text(module['name']));
                          }).toList(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        );
                      } else {
                        return Text('Please load courses');
                      }
                    }),
                Divider(color: Colors.white, height: 10),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: 'Title',
                      alignLabelWithHint: true,
                      hintText: 'e.g. Is there a python function for...',
                      border: OutlineInputBorder()),
                ),
                Divider(color: Colors.white, height: 10),
                TextFormField(
                  controller: bodyController,
                  maxLines: 10,
                  decoration: InputDecoration(
                      labelText: 'Question',
                      alignLabelWithHint: true,
                      hintText: 'Include as much information as possible...',
                      border: OutlineInputBorder()),
                ),
                Divider(color: Colors.white, height: 10),
                // Image Drop Section
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 160,
                          padding: EdgeInsets.all(10),
                          color: highlight == true ? Colors.grey : Colors.blue,
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
                          Container(
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
                  ],
                ),
                Divider(color: Colors.white, height: 10),
                Container(
                  child: ElevatedButton.icon(
                    onPressed: () => {makePost()},
                    icon: Icon(Icons.post_add),
                    label: Text('Submit'),
                  ),
                ),
              ],
            ))));
  }

  // Function to combine all elemnts involved in making a post
  makePost() async {
    await uploadImage(file!, imageName: 'images/${DateTime.now()}');
    this._addQuestion();
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
  Future uploadImage(html.File image, {required String imageName}) async {
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
        URL = imageUri.toString();
      });
      // print(URL);
    } catch (e) {
      print(e);
    }
  }

  // TO DO:
  // Get image url and add it to column in firebase database for user post
}
