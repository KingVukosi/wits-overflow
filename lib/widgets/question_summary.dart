import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';

class QuestionSummary extends StatefulWidget {
  final String questionId;
  final Map<String, dynamic> data;

  QuestionSummary({required this.questionId, required this.data});

  @override
  _QuestionSummaryState createState() => _QuestionSummaryState();
}

class _QuestionSummaryState extends State<QuestionSummary> {
  late Future<int> _fetchVotesCount;

  @override
  void initState() {
    super.initState();

    this._fetchVotesCount =
        WitsOverflowData().fetchQuestionVoteCount(this.widget.questionId);
  }

  @override
  Widget build(BuildContext context) {
    Widget _createBadges() {
      List<Widget> list = <Widget>[];

      if (this.widget.data.containsKey('tags')) {
        for (var i = 0; i < this.widget.data['tags'].length; i++) {
          list.add(new Container(
            margin: EdgeInsets.only(right: 5),
            color: Colors.lightBlue.shade50,
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Text(this.widget.data['tags'][i])),
          ));
        }
      }

      return new Row(children: list);
    }

    return GestureDetector(
        onTap: () => {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          QuestionAndAnswersScreen(this.widget.data['id']))),
            },
        child: Center(
          child: Container(
              width: double.infinity,
              height: 115,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                      top: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [
                Container(
                  color: Colors.grey.shade100,
                  height: double.infinity,
                  width: 100,
                  child: Center(
                      child: FutureBuilder(
                          future: _fetchVotesCount,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text('${snapshot.data}\nvotes',
                                  textAlign: TextAlign.center);
                            } else {
                              return Text('0\nvotes',
                                  textAlign: TextAlign.center);
                            }
                          })),
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        height: double.infinity,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(this.widget.data['title'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColorDark,
                                    //fontWeight: FontWeight.bold
                                  )),
                              Divider(color: Colors.white, height: 4),
                              _createBadges(),
                              Divider(color: Colors.white, height: 5),
                              (this.widget.data['createdAt'] == null)
                                  ? SizedBox.shrink()
                                  : Text(
                                      (this.widget.data['createdAt']
                                              as Timestamp)
                                          .toDate()
                                          .toString(),
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).disabledColor))
                            ])))
              ])),
        ));
  }
}
