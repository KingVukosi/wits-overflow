import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

//ignore: must_be_immutable
class SearchResults extends StatefulWidget {
  final _firestore;
  final _auth;
  late final String keyword;

  SearchResults({Key? key, required keyword, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth,
        super(key: key) {
    this.keyword = keyword.toString().toLowerCase();
  }

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<Widget> questionSummaryWidgets = [];
  WitsOverflowData witsOverflowData = WitsOverflowData();

  bool _questionMatchKeyWord(Map<String, dynamic> question) {

    bool found = false;

    bool _questionTagsMatchKeyWord(List<String> tags) {
      for (int i = 0; i < tags.length; i++) {
        if (tags[i].contains(this.widget.keyword)) {
          return true;
        }
      }
      return false;
    }

    if (question['title']
        .toString()
        .toLowerCase()
        .contains(this.widget.keyword)) {
      found = true;
    } else if (question['body']
        .toString()
        .toLowerCase()
        .contains(this.widget.keyword)) {
      found = true;
    } else if (_questionTagsMatchKeyWord(question['tags'])) {
      found = true;
    }
    return found;
  }

  void _getSearchResults() async {
    int limit = 50;
    QuerySnapshot<Map<String, dynamic>> patch = await this
        .widget
        ._firestore
        .collection(COLLECTIONS['questions'])
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    print('[SEARCH: MATCHED QUESTIONS (${patch.docs.length})]');
    while (patch.docs.isNotEmpty) {
      // QueryDocumentSnapshot<Map<String, dynamic>
      this.questionSummaryWidgets.addAll(
      patch.docs.where((question){
        Map<String, dynamic> questionData = question.data();
        questionData.addAll({'id': question.id});
        bool match = _questionMatchKeyWord(questionData);
        return match;
      }).toList()
      .map((question){
        Map<String, dynamic> questionData = question.data();
        questionData.addAll({'id': question.id});
        return FutureBuilder(
          future: Future.wait([
            this.witsOverflowData.fetchUserInformation(questionData['authorId']),
            this.witsOverflowData.fetchQuestionAnswers(questionData['id']),
            this.witsOverflowData.fetchQuestionVotes(questionData['id']),
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<Object?>> snapshot){
            if(snapshot.hasData){
              print('[FUTURE RETURNED, ADDING QUESTION SUMMARY WIDGET]');
              Map<String, dynamic> author = (snapshot.data?[0] as Map<String, dynamic>);

              List<Map<String, dynamic>> questionVotes = snapshot.data?[1] as List<Map<String, dynamic>>;

              List<Map<String, dynamic>> questionAnswers = snapshot.data?[2] as List<Map<String, dynamic>>;
              print('[QUESTION: $questionData, AUTHOR: $author, QUESTION VOTES: $questionVotes, QUESTION ANSWERS: $questionAnswers}]');
              // return Container(
              //   color: Colors.red,
              //   width: 100,
              //   height: 100,
              // );
              return new QuestionSummary(
                answers: questionAnswers,
                questionId: questionData['id'],
                title: questionData['title'],
                votes: questionVotes,
                createdAt: questionData['createdAt'],
                tags: questionData['tags'],
                authorDisplayName: author['displayName'],
              );
            }else if(snapshot.hasError){
              print('[FUTURE RETURNED WITH ERRORS]');
              return Text('ERRORS: (${questionData['id']})');
            }
            else{
              print('[FUTURE LOADING...]');
              return Container(
                color: Color.fromRGBO(100, 100, 100, 0.2),
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      }).toList());

      // ======================================================================
      this.setState((){

      });
      patch = await this
          .widget
          ._firestore
          .collection(COLLECTIONS['questions'])
          .orderBy('createdAt', descending: true)
          .startAfterDocument(patch.docs.elementAt(patch.docs.length - 1))
          .limit(limit)
          .get();
      print('[AFTER RETRIEVING PATH, SIZE: ${patch.docs.length}]');
    }
  }

  @override
  void initState() {
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);

    this._getSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    print('[_SearchResultsState.build, question widgets: ${this.questionSummaryWidgets}]');
    return WitsOverflowScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: ListView.builder(
        itemCount: this.questionSummaryWidgets.length,
        itemBuilder: (context, index){
          return this.questionSummaryWidgets[index];
        },
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        // children: this.questionSummaryWidgets,
        // children: [
        //   Container(
        //     color: Colors.white12,
        //     margin: EdgeInsets.fromLTRB(50, 20, 20, 50),
        //     child: Text(
        //       toTitleCase('${this.widget.keyword}'),
        //       style: TextStyle(
        //         fontSize: 30,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        //   ListView(
          // SingleChildScrollView(
          //   padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: this.questionSummaryWidgets,
            // ),
          // ),
        // ],
      ),
    );
  }
}
