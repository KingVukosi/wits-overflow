import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

class PostQuestionScreen extends StatefulWidget {

  late final Future<List<Map<String, dynamic>>> coursesFuture;

  PostQuestionScreen() {
    coursesFuture = WitsOverflowData().fetchCourses();
  }

  @override
  _PostQuestionScreenState createState() => _PostQuestionScreenState();
}

class _PostQuestionScreenState extends State<PostQuestionScreen> {

  late List<Map<String, dynamic>>? _courses;
  late List<Map<String, dynamic>>? _modules;

  late Future<List<Map<String, dynamic>>> modulesFuture;

  String? _selectedCourseId;
  String? _selectedCourseCode;
  String? _selectedModuleId;
  String? _selectedModuleCode;

  final titleController = new TextEditingController();
  final bodyController = new TextEditingController();

  void _notify(message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1
    );
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

      WitsOverflowData().addQuestion({
        'createdAt': DateTime.now(),
        'courseId': _selectedCourseId,
        'moduleId': _selectedModuleId,
        'title': titleController.text,
        'body': bodyController.text,
        'tags': [
          _selectedCourseCode,
          _selectedModuleCode
        ]
      });

      _notify('Question added.');

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
      modulesFuture = WitsOverflowData().fetchModules(this._selectedCourseId);
      super.setState(fn);
    }

  @override
  void initState() {
    modulesFuture = WitsOverflowData().fetchModules(this._selectedCourseId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WitsOverflowScaffold(
      body:
      Container(
        padding: EdgeInsets.all(10),
        child: Form(
        child: Column(children: [

          FutureBuilder<List<Map<String, dynamic>>>(
            
            future: widget.coursesFuture,
            builder: (context, snapshot) {

              if(snapshot.hasError) {
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
                     return  DropdownMenuItem<String?>(value: course['id'], child: Text(course['name']) );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                );

              } 
              else {
                return Text('Please load courses');
              }

            }
          ),

          Divider(color: Colors.white, height: 10),

          FutureBuilder<List<Map<String, dynamic>>>(
            
            future: modulesFuture,
            builder: (context, snapshot) {

              if(snapshot.hasError) {
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
                     return  DropdownMenuItem<String?>(value: module['id'], child: Text(module['name']) );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                );

              } 
              else {
                return Text('Please load courses');
              }

            }
          ),

          Divider(color: Colors.white, height: 10),

          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
                labelText: 'Title',
                alignLabelWithHint: true,
                hintText: 'e.g. Is there a python function for...',
                border: OutlineInputBorder()
            ),
          ),

          Divider(color: Colors.white, height: 10),
          
          TextFormField(
            controller: bodyController,
            maxLines: 10,
            decoration: InputDecoration(
                labelText: 'Question',
                alignLabelWithHint: true,
                hintText: 'Include as much information as possible...',
                border: OutlineInputBorder()
            ),
          ),

          Divider(color: Colors.white, height: 10),

          ElevatedButton.icon(
              onPressed: () => {
                this._addQuestion()
              },
              icon: Icon(Icons.post_add),
              label: Text('Submit your question'),
          )

      ],))
    ));

  }
}

