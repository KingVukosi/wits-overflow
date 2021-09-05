// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// ignore: must_be_immutable
class ModuleQuestionsScreen extends StatefulWidget {
  final String moduleId;

  ModuleQuestionsScreen({Key? key, required this.moduleId}) : super(key: key);

  @override
  _ModuleQuestionsScreenState createState() => _ModuleQuestionsScreenState();
}

class _ModuleQuestionsScreenState extends State<ModuleQuestionsScreen> {
  late bool _loading;

  late Future<List<Map<String, dynamic>>> questions;

  @override
  void initState() {
    super.initState();

    this._loading = true;

    questions =
        WitsOverflowData().fetchModuleQuestions(moduleId: this.widget.moduleId);
  }

  @override
  Widget build(BuildContext context) {
    return WitsOverflowScaffold(
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: questions,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                this._loading = false;

                return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? data = snapshot.data?[index];
                      if (data != null) {
                        return QuestionSummary(
                            questionId: data['id'], data: data);
                      } else {
                        return SizedBox.shrink();
                      }
                    });
              } else {
                if (this._loading == true) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Text('No questions in module.');
                }
              }
            }));
  }
}
