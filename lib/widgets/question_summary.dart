import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wits_overflow/screens/question_and_answers_screen.dart';
import 'package:wits_overflow/utils/functions.dart';

class QuestionSummary extends StatelessWidget {
  // final Map<String, dynamic> data;
  final String questionId;
  final String title;
  final String authorDisplayName;
  final List tags;
  final List<Map<String, dynamic>> votes;
  final List<Map<String, dynamic>> answers;
  final Timestamp createdAt;

  QuestionSummary({
    required this.questionId,
    required this.title,
    required this.tags,
    required this.votes,
    required this.createdAt,
    required this.answers,
    required this.authorDisplayName,
  });

  bool _hasAcceptedAnswer() {
    bool result = false;
    for (var i = 0; i < this.answers.length; i++) {
      if (this.answers[i]['accepted'] == true) {
        result = true;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Widget _createBadges() {
      List<Widget> list = <Widget>[];

      for (var i = 0; i < this.tags.length; i++) {
        list.add(Container(
          margin: EdgeInsets.only(right: 5),
          color: Color.fromRGBO(225, 236, 244, 1),
          child: Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                this.tags[i],
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromRGBO(57, 115, 157, 1),
                ),
              )),
        ));
      }
      return new Row(children: list);
    }

    return GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      QuestionAndAnswersScreen(this.questionId)));
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
                  color: this._hasAcceptedAnswer() == true
                      ? Color.fromRGBO(231, 251, 239, 1)
                      : Colors.grey.shade100,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  height: double.infinity,
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${countVotes(this.votes)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          SvgPicture.asset(
                            countVotes(this.votes) < 0
                                ? 'assets/icons/caret_down.svg'
                                : 'assets/icons/caret_up.svg',
                            semanticsLabel: 'Feed button',
                            placeholderBuilder: (context) {
                              return Icon(Icons.error,
                                  color: Colors.deepOrange);
                            },
                            height: 11,
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            this.answers.length.toString(),
                            style: TextStyle(
                              color: this._hasAcceptedAnswer() == true
                                  ? Color.fromRGBO(76, 144, 103, 1)
                                  : Colors.grey.shade100,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          SvgPicture.asset(
                            this._hasAcceptedAnswer() == true
                                ? 'assets/icons/question_answer_correct.svg'
                                : 'assets/icons/answer.svg',
                            semanticsLabel: 'Feed button',
                            placeholderBuilder: (context) {
                              return Icon(Icons.error,
                                  color: Colors.deepOrange);
                            },
                            height: 19,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        height: double.infinity,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(this.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(0, 116, 204, 1),
                                    fontWeight: FontWeight.bold,
                                    //fontWeight: FontWeight.bold
                                  )),

                              Divider(color: Colors.white, height: 4),

                              // badges/tags
                              _createBadges(),

                              Divider(color: Colors.white, height: 5),

                              // datetime
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: Text(
                                        formatDateTime(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                this
                                                    .createdAt
                                                    .millisecondsSinceEpoch)),
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .disabledColor)),
                                  ),

                                  // author display name
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                    child: Text(
                                      this.authorDisplayName,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ])))
              ])),
        ));
  }
}
