import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:wits_overflow/forms/question_answer_form.dart';
import 'package:wits_overflow/forms/question_comment_form.dart';
// import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:wits_overflow/widgets/answers.dart';
import 'package:wits_overflow/widgets/comments.dart';

// ---------------------------------------------------------------------------
//             Dashboard class
// ---------------------------------------------------------------------------
class QuestionAndAnswersScreen extends StatefulWidget {
  final String id; //question id

  late final _firestore; // = FirebaseFirestore.instance;
  late final _auth;

  QuestionAndAnswersScreen(this.id, {firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _QuestionState createState() =>
      _QuestionState(this.id, firestore: this._firestore, auth: this._auth);
}

class _QuestionState extends State<QuestionAndAnswersScreen> {
  final String id; // question id

  Map<String, dynamic>? question;

  List<Map<String, dynamic>> questionVotes = [];
  List<Map<String, dynamic>> questionComments = [];
  List<Map<String, dynamic>> questionAnswers = [];

  Map<String, dynamic>? questionUser;

  // holds user information for each question comment
  Map<String, Map<String, dynamic>> questionCommentsUsers =
      Map<String, Map<String, dynamic>>();

  // holds user information for each question answer
  Map<String, Map<String, dynamic>> questionAnswersUsers =
      Map<String, Map<String, dynamic>>();

  // holds votes information for each answer
  Map<String, List<Map<String, dynamic>>> questionAnswerVotes =
      Map<String, List<Map<String, dynamic>>>();

  // holds votes information for each answer
  Map<String, Map<String, dynamic>> questionAnswerEditors =
      Map<String, Map<String, dynamic>>();

  bool isBusy = true;

  late WitsOverflowData witsOverflowData = WitsOverflowData();

  late var _firestore;
  late var _auth;

  _QuestionState(this.id, {firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
    this.getData();
    super.initState();
  }

  Future<void> getData() async {
    // retrieve necessary data from firebase to view this page
    print(
        '[-------------------------------------------- [RETRIEVING DATA FROM FIREBASE] --------------------------------------------]');

    // get votes information for each answer
    Future<Map<String, List<Map<String, dynamic>>>> getAnswerVotes() async {
      Map<String, List<Map<String, dynamic>>> answerVotes = Map();
      for (var i = 0; i < this.questionAnswers.length; i++) {
        List<Map<String, dynamic>>? votes = await witsOverflowData
            .fetchQuestionAnswerVotes(this.id, this.questionAnswers[i]['id']);
        answerVotes.addAll({this.questionAnswers[i]['id']: votes!});
      }
      return answerVotes;
    }

    // get user information for each comment
    Future<Map<String, Map<String, dynamic>>> getCommentsUsers() async {
      Map<String, Map<String, dynamic>> commentsUsers = Map();
      for (var i = 0; i < this.questionComments.length; i++) {
        Map<String, dynamic>? user = await witsOverflowData
            .fetchUserInformation(this.questionComments[i]['authorId']);
        commentsUsers.addAll({this.questionComments[i]['id']: user!});
      }
      return commentsUsers;
    }

    // get user (author) information for each answer
    Future<Map<String, Map<String, dynamic>>> getAnswersUsers() async {
      Map<String, Map<String, dynamic>> answersUsers = Map();
      for (var i = 0; i < this.questionAnswers.length; i++) {
        Map<String, dynamic>? user = await witsOverflowData
            .fetchUserInformation(this.questionAnswers[i]['authorId']);
        answersUsers.addAll({this.questionAnswers[i]['id']: user!});
      }
      return answersUsers;
    }

    // for each answer, get user information the of the editor
    Future<Map<String, Map<String, dynamic>>> getAnswerEditors() async {
      Map<String, Map<String, dynamic>> editors = {};
      for (int i = 0; i < this.questionAnswers.length; i++) {
        String? editorId = this.questionAnswers[i]['editorId'];
        String answerId = this.questionAnswers[i]['id'];
        if (editorId != null) {
          Map<String, dynamic>? userInfo =
              await witsOverflowData.fetchUserInformation(editorId);
          if (userInfo != null) {
            editors.addAll({answerId: userInfo});
            // print('[USER INFORMATION FOR ANSWER WITH ID: ${answerId}]');
          }
        }
      }
      return editors;
    }

    this.question = await witsOverflowData.fetchQuestion(this.id);
    print('[QUESTION ID: ${this.question?['id']}]');

    List<Map<String, dynamic>>? fQuestionVotes =
        await witsOverflowData.fetchQuestionVotes(this.id);
    this.questionVotes.addAll(fQuestionVotes == null ? [] : fQuestionVotes);
    List<Map<String, dynamic>>? fQuestionComments =
        await witsOverflowData.fetchQuestionComments(this.id);
    this
        .questionComments
        .addAll(fQuestionComments == null ? [] : fQuestionComments);
    List<Map<String, dynamic>>? fQuestionAnswers =
        await witsOverflowData.fetchQuestionAnswers(this.id);
    this
        .questionAnswers
        .addAll(fQuestionAnswers == null ? [] : fQuestionAnswers);

    this.questionAnswerVotes = await getAnswerVotes();
    this.questionAnswersUsers = await getAnswersUsers();
    this.questionAnswerEditors = await getAnswerEditors();
    this.questionCommentsUsers = await getCommentsUsers();

    // stores information of the user that first asked the question
    this.questionUser =
        await witsOverflowData.fetchUserInformation(this.question!['authorId']);

    print(
        '[-------------------------------------------- [RETRIEVED DATA FROM FIREBASE] --------------------------------------------]');
    setState(() {
      this.isBusy = false;
    });
  }

  Widget buildCommentsWidget() {
    List<Widget> comments = <Widget>[];
    for (var i = 0; i < this.questionComments.length; i++) {
      Map<String, dynamic> questionComment = this.questionComments[i];
      Map<String, dynamic> commentUser =
          this.questionCommentsUsers[questionComment['id']]!;
      String displayName = commentUser['displayName'];
      String body = questionComment['body'];
      comments.add(Comment(
          body: body,
          displayName: displayName,
          commentedAt: questionComment['commentedAt']));
    }

    comments.add(Container(
      child: TextButton(
        child: Text('add comment'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return QuestionCommentForm(this.question!['id'],
                    this.question!['title'], question!['body']);
              },
            ),
          );
        },
      ),
    ));

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        children: comments,
      ),
    );
  }

  // void _addFavouriteQuestion() {
  //   User? currentUser = witsOverflowData.getCurrentUser();
  //   if (currentUser != null) {
  //
  //     String questionId = this.id;
  //     String userId = currentUser.uid;
  //
  //     witsOverflowData.addFavouriteQuestion(
  //       userId: userId,
  //       questionId: questionId
  //     ).then((result) {
  //         showNotification(context, 'Favourite added.');
  //     });
  //   }
  // }

  // void changeAnswerStatus({required String answerId}) async{
  //   setState(() {
  //     this.isBusy = true;
  //   });
  //   // if the user is the author of the question
  //
  //   // retrieve answer from database
  //   CollectionReference<Map<String, dynamic>> questionAnswersCollection = FirebaseFirestore.instance.collection('questions-2').doc(this.id).collection('answers');
  //   DocumentSnapshot<Map<String, dynamic>> answer = await questionAnswersCollection.doc(answerId).get();
  //   bool accepted = (answer.data()!['accepted'] == null)  ? false : answer.data()!['accepted'];
  //
  //   bool value = false;
  //   if( accepted == true){
  //     // change answer
  //     value = false;
  //   }
  //   else{
  //     value = true;
  //     // all other answer should change status
  //     QuerySnapshot<Map<String, dynamic>> acceptedAnswer = await questionAnswersCollection.where('accepted', isEqualTo: true).get();
  //     for(var i = 0; i < acceptedAnswer.docs.length; i++){
  //       acceptedAnswer.docs.elementAt(i).reference.update({'accepted': false});
  //     }
  //   }
  //
  //   answer.reference.update({'accepted': value}).then((value){
  //     showNotification('Changed answer status');
  //     Navigator.push(context, MaterialPageRoute(
  //         builder: (BuildContext context){
  //           return QuestionAndAnswersScreen(this.id);
  //         }
  //     ))
  //     .catchError((error){
  //       showNotification('Error occurred');
  //     });
  //   });
  //
  //   setState(() {
  //     this.isBusy = false;
  //   });
  // }

  // QueryDocumentSnapshot getAnswer({required String answerId}){
  //   // returns answer (as QuerySnapsShot) from answers
  //   for(var i = 0; i < this.questionAnswers!.docs.length; i++){
  //     if(this.questionAnswers!.docs.elementAt(i).id == answerId){
  //       return this.questionAnswers!.docs.elementAt(i);
  //     }
  //   }
  //   throw Exception("Could not find answer(id: $answerId) from available answers");
  // }

  Widget buildAnswersWidget() {
    List<Widget> answers = <Widget>[];
    for (var i = 0; i < this.questionAnswers.length; i++) {
      bool? accepted = this.questionAnswers[i]['accepted'];
      String answerId = this.questionAnswers[i]['id'];
      var editedAt = this.questionAnswers[i]['editedAt'];
      String authorDisplayName =
          this.questionAnswersUsers[answerId]!['displayName'];
      List<Map<String, dynamic>>? votes =
          this.questionAnswerVotes[this.questionAnswers[i]['id']];
      String? editorDisplayName =
          this.questionAnswerEditors[answerId]?['displayName'];
      // print('[editorDisplayName: $editorDisplayName, editedAt: ${editedAt?.toDate()}]');
      answers.add(
        Answer(
          id: this.questionAnswers[i]['id'],
          authorDisplayName: authorDisplayName,
          votes: votes == null ? [] : votes,
          body: this.questionAnswers[i]['body'],
          answeredAt: (this.questionAnswers[i]['answeredAt'] as Timestamp),
          accepted: accepted == null ? false : accepted,
          authorId: this.questionAnswers[i]['authorId'],
          questionId: this.question!['id'],
          questionAuthorId: this.question!['authorId'],
          editorDisplayName: editorDisplayName,
          editedAt: editedAt,
          firestore: this._firestore,
          auth: this._auth,
        ),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: answers,
      ),
    );
  }

  int _calculateVotes(List<Map<String, dynamic>> votes) {
    int v = 0;
    for (var i = 0; i < votes.length; i++) {
      v += (votes[i]['value']) as int;
    }
    return v;
  }

  @override
  Widget build(BuildContext context) {
    //
    print('[this._firestore : ${this._firestore}]');
    if (this.isBusy) {
      return WitsOverflowScaffold(
        firestore: this._firestore,
        auth: this._auth,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WitsOverflowScaffold(
      firestore: this._firestore,
      auth: this._auth,
      body: Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              /// question title and body
              /// votes, up-vote and down-vote
              QuestionWidget(
                id: this.id,
                title: this.question!['title'],
                body: this.question!['body'],
                // votes: this.questionVotes!.length,
                votes: this._calculateVotes(this.questionVotes),
                createdAt: this.question!['createdAt'],
                authorDisplayName: this.questionUser!['displayName'],
                auth: this._auth,
                firestore: this._firestore,
              ),

              /// comments
              /// comments header
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(239, 240, 241, 1),
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(214, 217, 220, 1),
                    ),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),

              /// comments list
              this.buildCommentsWidget(),

              /// answers
              /// answers header
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(239, 240, 241, 1),
                  border: Border(
                    bottom: BorderSide(
                      color: Color.fromRGBO(214, 217, 220, 1),
                    ),
                  ),
                ),
                // color: Color(0xff2980b9),
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${this.questionAnswers.length.toString()} answers',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return QuestionAnswerForm(
                                this.question!['id'],
                                this.question!['title'],
                                this.question!['body']);
                          }),
                        );
                      },
                      child: Icon(Icons.add),
                    )
                  ],
                ),
              ),

              /// answers list
              this.buildAnswersWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
