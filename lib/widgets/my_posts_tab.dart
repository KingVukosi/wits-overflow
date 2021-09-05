import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

// ignore: must_be_immutable
class MyPostsTab extends StatefulWidget {
  late Future<List<Map<String, dynamic>>> questions;

  MyPostsTab() {
    questions = WitsOverflowData()
        .fetchUserQuestions(userId: FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  _MyPostsTabState createState() => _MyPostsTabState();
}

class _MyPostsTabState extends State<MyPostsTab> {
  late bool _loading;

  @override
  void initState() {
    super.initState();

    this._loading = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.questions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            this._loading = false;

            return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic>? data = snapshot.data?[index];
                  if (data != null) {
                    return QuestionSummary(questionId: data['id'], data: data);
                  } else {
                    return SizedBox.shrink();
                  }
                });
          } else {
            if (this._loading == true) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Text('You have not asked any quesions.');
            }
          }
        });
  }
}
