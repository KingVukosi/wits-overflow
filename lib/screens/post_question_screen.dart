import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

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
  late final Future<List<Map<String, dynamic>>> coursesFuture;

  late List<Map<String, dynamic>>? _courses;
  late List<Map<String, dynamic>>? _modules;

  late Future<List<Map<String, dynamic>>> modulesFuture;

  XFile? _image; // Used only if you need a single picture
  Uint8List? imageForSendToAPI;
  // U

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
      witsOverflowData.addQuestion(
        createdAt: DateTime.now(),
        courseId: _selectedCourseId!,
        moduleId: _selectedModuleId!,
        title: titleController.text,
        body: bodyController.text,
        authorId: witsOverflowData.getCurrentUser()!.uid,
        image: this._image,
        tags: [_selectedCourseCode!, _selectedModuleCode!]
      ).then((Map<String, dynamic> question) {
        _notify('Question added.');
        Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) {
            return QuestionAndAnswersScreen(question['id']);
          },
        ));
      }).catchError((error) {

        print('[ERROR OCCURRED : $error]');
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

  Future getImage(bool gallery) async {
    // ImagePicker picker = ImagePicker();
    // PickedFile? pickedFile;
    // Let user select photo from gallery

    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    // if(gallery) {
    //   pickedFile = await picker.pickImage(
    //     source: ImageSource.gallery,);
    // }
    // // Otherwise open camera to get new photo
    // else{
    //   pickedFile = await picker.getImage(
    //     source: ImageSource.camera,);
    // }

    if(image != null){
      imageForSendToAPI = await image.readAsBytes();

    }
    setState(() {
      if (image != null) {
        // _images.add(File(pickedFile.path));
        // _image = File(pickedFile.path); // Use if you only need a single picture
        _image = image;
        // _image = File(image.path, );
        // if (kIsWeb) {
        //   _image = Image.network(pickedFile.path);
        // } else {
        //   _image = Image.file(File(pickedFile.path));
        // }
      } else {
        print('No image selected.');
      }
    });
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

                RawMaterialButton(
                  fillColor: Theme.of(context).hintColor,
                  child: Icon(Icons.add_photo_alternate_rounded,
                    color: Colors.white,),
                  elevation: 8,
                  onPressed: () {
                    getImage(true);
                  },
                  padding: EdgeInsets.all(15),
                  shape: CircleBorder(),
                ),
                Divider(color: Colors.white, height: 10),
                Container(
                  child: ElevatedButton.icon(
                    onPressed: () => {this._addQuestion()},
                    icon: Icon(Icons.post_add),
                    label: Text('Submit'),
                  ),
                ),
                Divider(color: Colors.white, height: 10),
                _image == null ? Container(padding: EdgeInsets.all(10)) :
                Container(
                    child: kIsWeb ? Image.network(_image!.path) : Image.file(File(_image!.path)),
                )

              ],
            ))));
  }
}
