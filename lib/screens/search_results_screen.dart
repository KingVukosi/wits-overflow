import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/favourites_tab.dart';
import 'package:wits_overflow/widgets/my_posts_tab.dart';
import 'package:wits_overflow/widgets/question.dart';
import 'package:wits_overflow/widgets/recent_activity_tab.dart';
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
        super(key: key){
    this.keyword = keyword.toString().toLowerCase();
  }

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {

  List<Widget> questions = [];
  WitsOverflowData witsOverflowData = WitsOverflowData();

  bool _questionMatchKeyWord(Map<String, dynamic> question){
    bool found = false;

    bool _questionTagsMatchKeyWord(List<String> tags){
      for(int i = 0; i < tags.length; i++){
        if(tags[i].contains(this.widget.keyword)){
          return true;
        }
      }
      return false;
    }

    if(question['title'].toString().toLowerCase().contains(this.widget.keyword)){
      found = true;
    }
    else if(question['body'].toString().toLowerCase().contains(this.widget.keyword)){
      found = true;
    }
    else if(_questionTagsMatchKeyWord(question['tags'])){
      found = true;
    }
    return found;
  }

  void _getSearchResults() async {
    int limit = 50;
    QuerySnapshot<Map<String, dynamic>> patch = await FirebaseFirestore.instance.collection(COLLECTIONS['questions']).limit(limit).get();
    while(patch.docs.isNotEmpty) {
      for (int i = 0; i < patch.docs.length; i++) {
        Map<String, dynamic> question = patch.docs.elementAt(i).data();
        question.addAll({'id': patch.docs.elementAt(i).id});
        if (_questionMatchKeyWord(question)) {
          // add to question list

          // get question:
          //    * votes
          //    * author's uid & display name
          String questionId = patch.docs
              .elementAt(i)
              .id;
          Map<String, dynamic> author = (await this.witsOverflowData
              .fetchUserInformation(question['authorId']))!;
          List<Map<String, dynamic>>? questionVotes = await this
              .witsOverflowData.fetchQuestionVotes(questionId);
          late int votes;
          if (questionVotes == null) {
            votes = 0;
          }
          else {
            votes = countVotes(questionVotes);
          }


          this.setState(() {
            print('[MATCH FOUND: $question, ADDING TO QUESTIONS LIST]');
            this.questions.add(
                new QuestionWidget(
                  id: questionId,
                  title: question['title'],
                  body: question['body'],
                  votes: votes,
                  createdAt: question['createdAt'],
                  authorDisplayName: author['displayName'],
                  authorId: author['id'],
                )
            );
          });
        }
      }
      patch = await FirebaseFirestore.instance.collection(COLLECTIONS['questions']).limit(limit).get();
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
    print('[SEARCH RESULTS: build]');
    return WitsOverflowScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: ListView(
        children: this.questions,
      )
    );
  }
}
