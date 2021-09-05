import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wits_overflow/forms/question_answer_form.dart';
import 'package:wits_overflow/forms/question_comment_form.dart';
import 'package:wits_overflow/utils/functions.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// ---------------------------------------------------------------------------
//             Dashboard class
// ---------------------------------------------------------------------------
class QuestionAndAnswersScreen extends StatefulWidget {
  final String id; //question id

  QuestionAndAnswersScreen(this.id);

  @override
  _QuestionState createState() => _QuestionState(this.id);
}

class _QuestionState extends State<QuestionAndAnswersScreen> {
  final String id; // question id

  DocumentSnapshot<Map<String, dynamic>>? question;

  QuerySnapshot<Map<String, dynamic>>? questionVotes;
  QuerySnapshot<Map<String, dynamic>>? questionComments;
  QuerySnapshot<Map<String, dynamic>>? questionAnswers;

  DocumentSnapshot<Map<String, dynamic>>? questionUser;

  Map<String, DocumentSnapshot<Map<String, dynamic>>> commentsUsers =
      Map<String, DocumentSnapshot<Map<String, dynamic>>>();
  Map<String, DocumentSnapshot<Map<String, dynamic>>> answersUsers =
      Map<String, DocumentSnapshot<Map<String, dynamic>>>();
  Map<String, QuerySnapshot> answerVotes = Map<String, QuerySnapshot>();

  bool isBusy = true;

  _QuestionState(this.id) {
    //this.getData();
  }

  @override
  void initState() {
    this.getData();
    super.initState();
  }

  Future<void> getData() async {
    // retrieve necessary data from firebase to view this page

    print(
        '[-------------------------------------------- [RETRIEVING DATA FROM FIREBASE] --------------------------------------------]');

    // get votes information for each answer
    Future<Map<String, QuerySnapshot>> getAnswerVotes() async {
      Map<String, QuerySnapshot> votes = Map();
      for (var i = 0; i < this.questionAnswers!.docs.length; i++) {
        votes.addAll({
          this.questionAnswers!.docs[i].id: await FirebaseFirestore.instance
              .collection('questions-2')
              .doc(this.id)
              .collection('answers')
              .doc(this.questionAnswers!.docs[i].id)
              .collection('votes')
              .get()
        });
      }
      return votes;
    }

    // get user information for each comment
    Future<Map<String, DocumentSnapshot<Map<String, dynamic>>>>
        getCommentsUsers() async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> commentsUsers = Map();
      for (var i = 0; i < this.questionComments!.docs.length; i++) {
        commentsUsers.addAll({
          this.questionComments!.docs[i].id: await FirebaseFirestore.instance
              .collection('users')
              .doc(this.questionComments!.docs[i].get('authorId'))
              .get()
        });
      }
      return commentsUsers;
    }

    // get user information for each answer
    Future<Map<String, DocumentSnapshot<Map<String, dynamic>>>>
        getAnswersUsers() async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> answersUsers = Map();
      for (var i = 0; i < this.questionAnswers!.docs.length; i++) {
        print(
            '[ADDING USER INFORMATION TO ANSWER WITH ID: ${this.questionAnswers!.docs[i].id}]');
        DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(this.questionAnswers!.docs[i].get('authorId'))
            .get();
        answersUsers.addAll({this.questionAnswers!.docs[i].id: user});
        print('[USER: id: ${user.id}]');
        // print('[USER INFORMATION ADDED TO ANSWER WITH ID: ${this.answers!.docs[i].id}, user.uid: ${answersUsers[this.answers!.docs[i].id]!.id}, user.displayName: ${answersUsers[this.answers!.docs[i].id]!.get('displayName')}]');
      }
      return answersUsers;
    }

    this.question = await FirebaseFirestore.instance
        .collection("questions-2")
        .doc(this.id)
        .get();

    // stores information of the user that first asked the question
    this.questionUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(this.question!.get('authorId'))
        .get();
    this.questionVotes = await FirebaseFirestore.instance
        .collection('questions-2')
        .doc(this.id)
        .collection('votes')
        .get();
    this.questionComments = await FirebaseFirestore.instance
        .collection('questions-2')
        .doc(this.id)
        .collection('comments')
        .get();
    this.questionAnswers = await FirebaseFirestore.instance
        .collection('questions-2')
        .doc(this.id)
        .collection('answers')
        .get();

    this.answerVotes = await getAnswerVotes();
    this.answersUsers = await getAnswersUsers();
    this.commentsUsers = await getCommentsUsers();

    print(
        '[-------------------------------------------- [RETRIEVED DATA FROM FIREBASE] --------------------------------------------]');
    setState(() {
      this.isBusy = false;
    });
  }

  Widget buildCommentsWidget() {
    // TODO: remote the following lines in production
    Widget buildCommentWidget(
        {required String displayName,
        required String body,
        required DateTime createdAt}) {
      return Container(
        padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              // color: Color,
              color: Color.fromARGB(50, 100, 100, 100),
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// user first and last names
            /// user comment
            Container(alignment: Alignment.centerLeft, child: Text(body)),

            /// comment: time and user
            Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // datetime
                  /// comment datetime
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Text(
                      formatDateTime(createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  // user
                  /// comment user
                  Container(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    print(
        '[QUESTION COMMENTS LENGTH : ${this.questionComments!.docs.length.toString()}]');
    List<Widget> comments = <Widget>[];
    for (var i = 0; i < this.questionComments!.docs.length; i++) {
      // this.comments!.docs.forEach((commentDoc) {
      QueryDocumentSnapshot<Map<String, dynamic>> commentDoc =
          this.questionComments!.docs[i];
      print('[CREATING COMMENT WIDGET]');
      DocumentSnapshot<Map<String, dynamic>> commentUser =
          this.commentsUsers[commentDoc.id]!;
      String displayName;
      if (commentUser.data() == null) {
        displayName = '[user information not in database]';
      } else {
        displayName = getField(commentUser.data()!, 'displayName',
            onNull: '?display name?', onError: '?display name?');
      }
      String body = getField(commentDoc.data(), 'body',
          onError: '[error, body not found for this comment]');
      DateTime createdAt = getField(commentDoc.data(), 'createAt',
          onError: DateTime.now(), onNull: DateTime.now());
      comments.add(buildCommentWidget(
          body: body, displayName: displayName, createdAt: createdAt));
    }

    comments.add(Container(
      child: TextButton(
        child: Text('add comment'),
        onPressed: () {
          print('[ADD COMMENT BUTTON PRESSED]');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return QuestionCommentForm(this.question!.id,
                    this.question!.get('title'), question!.get('body'));
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

  void voteQuestion({required int value}) async {
    //Future<DocumentSnapshot<Map<String, dynamic>>> vote;
    Map<String, dynamic> data = {
      'value': value,
      'user': FirebaseAuth.instance.currentUser!.uid,
      'votedAt': DateTime.now(),
    };

    String userUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> questionVotesCollection =
        FirebaseFirestore.instance
            .collection('questions-2')
            .doc(this.question!.id)
            .collection('votes');

    QuerySnapshot<Map<String, dynamic>> questionUserVote =
        await questionVotesCollection.where('user', isEqualTo: userUid).get();
    if (questionUserVote.docs.isEmpty) {
      questionVotesCollection.add(data).then((value) {
        final snackBar = SnackBar(
          content: Text(
            'Vote added',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          // backgroundColor: Colors.greenAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // TODO: reload the question page to reflect changes question page
      }).catchError((error) {
        // TODO: show message that error has occurred
        final snackBar = SnackBar(
          content: Text(
            'Error occurred',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          // backgroundColor: Colors.deepOrangeAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = SnackBar(content: Text('Already voted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _notify(message) {
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

    // Fluttertoast.showToast(
    //   msg: message,
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.CENTER,
    //   timeInSecForIosWeb: 1
    // );
  }

  void _addFavouriteQuestion() {
    if (FirebaseAuth.instance.currentUser != null) {
      String questionId = this.id;
      String userId = FirebaseAuth.instance.currentUser!.uid;

      WitsOverflowData()
          .addFavouriteQuestion(userId: userId, questionId: questionId)
          .then((result) {
        _notify('Favourite added.');
      });
    }
  }

  void changeAnswerStatus({required String answerId}) async {
    setState(() {
      this.isBusy = true;
    });
    // if the user is the author of the question

    // retrieve answer from database
    CollectionReference<Map<String, dynamic>> questionAnswersCollection =
        FirebaseFirestore.instance
            .collection('questions-2')
            .doc(this.id)
            .collection('answers');
    DocumentSnapshot<Map<String, dynamic>> answer =
        await questionAnswersCollection.doc(answerId).get();
    bool accepted = (answer.data()!['accepted'] == null)
        ? false
        : answer.data()!['accepted'];

    bool value = false;
    if (accepted == true) {
      // change answer
      value = false;
    } else {
      value = true;
      // all other answer should change status
      QuerySnapshot<Map<String, dynamic>> acceptedAnswer =
          await questionAnswersCollection
              .where('accepted', isEqualTo: true)
              .get();
      for (var i = 0; i < acceptedAnswer.docs.length; i++) {
        acceptedAnswer.docs.elementAt(i).reference.update({'accepted': false});
      }
    }

    answer.reference.update({'accepted': value}).then((value) {
      _notify('Changed answer status');
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return QuestionAndAnswersScreen(this.id);
      })).catchError((error) {
        _notify('Error occurred');
      });
    });

    setState(() {
      this.isBusy = false;
    });
  }

  String getQuestionBody() {
    // TODO: get body field properly
    // check whether 'body' field exist in the document snapshot question
    // if you try to access it and its not there, it will give error
    return this.question!.get('body');
  }

  String getQuestionTitle() {
    // TODO: get title field properly
    // check whether 'title' field exist in the document snapshot question
    // if you try to access it and its not there, it will give error
    return this.question!.get('title');
  }

  QueryDocumentSnapshot getAnswer({required String answerId}) {
    // returns answer (as QuerySnapsShot) from answers
    for (var i = 0; i < this.questionAnswers!.docs.length; i++) {
      if (this.questionAnswers!.docs.elementAt(i).id == answerId) {
        return this.questionAnswers!.docs.elementAt(i);
      }
    }
    throw Exception(
        "Could not find answer(id: $answerId) from available answers");
  }

  void voteAnswer({required String answerId, required int value}) async {
    // check if user has already voted on this answer

    String userUid = FirebaseAuth.instance.currentUser!.uid;
    QueryDocumentSnapshot answer = this.getAnswer(answerId: answerId);
    CollectionReference<Map<String, dynamic>> answerVotesReference =
        answer.reference.collection('votes');
    QuerySnapshot<Map<String, dynamic>> userVote = await answerVotesReference
        .where('user', isEqualTo: userUid)
        .limit(1)
        .get();

    if (userVote.docs.isEmpty) {
      // then the user can vote
      Map<String, dynamic> data = {
        'votedAt': DateTime.now(),
        'user': userUid,
        'value': value,
      };

      answerVotesReference.add(data).then((value) {
        // show that the vote was successful
        final snackBar = SnackBar(
          content: Text(
            'Vote added',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          // backgroundColor: Colors.greenAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }).catchError((error) {
        // show that there was an error while submitting
        final snackBar = SnackBar(
          content: Text(
            'Error occurred',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          // backgroundColor: Colors.greenAccent,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = SnackBar(
        content: Text(
          'Already voted',
          style: TextStyle(),
        ),
        // backgroundColor: Colors.greenAccent,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget buildAnswersWidget() {
    Widget buildAnswerWidget(
        {required String body,
        required String votes,
        required answeredAt,
        required String answerId,
        bool accepted = false}) {
      print('[BUILDING AN ANSWER WIDGET answerId \'$answerId\']');

      /// answer widget
      // Widget getAnswerStatus(){
      //   if(accepted == true){
      //     // // if answer is correct
      //     return GestureDetector(
      //       onTap: (){this.changeAnswerStatus(answerId: answerId);},
      //       child: SvgPicture.asset(
      //         'assets/icons/answer_correct.svg',
      //         semanticsLabel: 'Feed button',
      //         placeholderBuilder: (context) {
      //           return Icon(Icons.error, color: Colors.deepOrange);
      //         },
      //         height: 25,
      //       ),
      //     );

      //   }else{
      //     if(this.question!.data()!['authorId'] == FirebaseAuth.instance.currentUser!.uid){
      //       return GestureDetector(
      //         onTap: (){this.changeAnswerStatus(answerId: answerId);},
      //         child: SvgPicture.asset(
      //           'assets/icons/answer_correct.svg',
      //           semanticsLabel: 'Feed button',
      //           placeholderBuilder: (context) {
      //             return Icon(Icons.error, color: Colors.deepOrange);
      //           },
      //           height: 25,
      //         ),
      //       );
      //     }
      //     else{
      //       return Padding(padding: EdgeInsets.all(0),);
      //     }
      //   }
      // }
      Widget getAnswerStatus() {
        if (accepted == true) {
          // // if answer is correct
          return GestureDetector(
            onTap: () {
              this.changeAnswerStatus(answerId: answerId);
            },
            child: SvgPicture.asset(
              'assets/icons/answer_correct.svg',
              semanticsLabel: 'Feed button',
              placeholderBuilder: (context) {
                return Icon(Icons.error, color: Colors.deepOrange);
              },
              height: 25,
            ),
          );
        } else {
          if (this.question!.data()!['authorId'] ==
              FirebaseAuth.instance.currentUser!.uid) {
            return GestureDetector(
              onTap: () {
                this.changeAnswerStatus(answerId: answerId);
              },
              child: SvgPicture.asset(
                'assets/icons/answer_correct_placeholder.svg',
                semanticsLabel: 'Feed button',
                placeholderBuilder: (context) {
                  return Icon(Icons.error, color: Colors.deepOrange);
                },
                height: 25,
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(0),
            );
          }
        }
      }

      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// update vote button, down vote button, votes, question body
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(239, 240, 241, 1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  /// answer up vote button, down vote button, votes vote button
                  Expanded(
                    flex: 0,
                    child: Container(
                      color: Color.fromRGBO(239, 240, 241, 1),
                      child: Column(
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              this.voteAnswer(value: 1, answerId: answerId);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(0, 0),
                              padding: EdgeInsets.all(0.5),
                              // backgroundColor: Colors.black12,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/caret_up.svg',
                              semanticsLabel: 'Feed button',
                              placeholderBuilder: (context) {
                                return Icon(Icons.error,
                                    color: Colors.deepOrange);
                              },
                              height: 12.5,
                            ),
                          ),

                          Text(
                            votes,
                            style: TextStyle(
                                // backgroundColor: Colors.black12,
                                // fontSize: 20,
                                ),
                          ),

                          TextButton(
                            onPressed: () {
                              this.voteAnswer(answerId: answerId, value: -1);
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(0, 0),
                              padding: EdgeInsets.all(0.5),
                              // backgroundColor: Colors.black12,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/caret_down.svg',
                              semanticsLabel: 'Feed button',
                              placeholderBuilder: (context) {
                                return Icon(Icons.error,
                                    color: Colors.deepOrange);
                              },
                              height: 12.5,
                            ),
                          ),

                          // answer status
                          getAnswerStatus(),
                        ],
                      ),
                    ),
                  ),

                  /// answer body
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        body,
                        textAlign: TextAlign.left,
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// creator information
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0.5,
                    color: Color.fromRGBO(239, 240, 241, 1),
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // user information
                  Container(
                    child: Row(
                      children: [
                        VerticalDivider(width: 5, color: Colors.transparent),
                        // user avatar image
                        ClipOval(
                            child: Image(
                                height: 25,
                                width: 25,
                                //image: AssetImage('assets/images/default_avatar.png'))
                                image: NetworkImage(FirebaseAuth
                                    .instance.currentUser!.photoURL!))),

                        VerticalDivider(width: 10, color: Colors.transparent),

                        // user information (display name, metadata)
                        Column(
                          children: [
                            // user display name
                            Text(
                                this.answersUsers[answerId]!.get('displayName'),
                                style: TextStyle(
                                  color: Colors.blue,
                                )),
                            // user metadata
                            Row(
                              children: [],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // datetime
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'answered at',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).disabledColor
                              // backgroundColor: Colors.black12,
                              ),
                        ),
                        Text(
                          answeredAt,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).disabledColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// update information
            Row(),

            // comments
            Container(),

            //add
          ],
        ),
      );
    }

    List<Widget> answers = <Widget>[];
    for (var i = 0; i < this.questionAnswers!.docs.length; i++) {
      print(
          '[GETTING QUESTION ANSWER VOTES WITH ID: ${this.questionAnswers!.docs[i].id.toString()}, this.answerVotes.keys().toString: ${this.answerVotes.keys.toString()}]');
      bool? accepted =
          this.questionAnswers!.docs.elementAt(i).data()['accepted'];
      answers.add(
        buildAnswerWidget(
          votes: this
              .answerVotes[this.questionAnswers!.docs[i].id.toString()]!
              .docs
              .length
              .toString(),
          body: this.questionAnswers!.docs[i].get('body'),
          answeredAt: formatDateTime(DateTime.fromMillisecondsSinceEpoch((this
                  .questionAnswers!
                  .docs
                  .elementAt(i)
                  .get('answeredAt') as Timestamp)
              .millisecondsSinceEpoch)),
          answerId: this.questionAnswers!.docs.elementAt(i).id,
          accepted: accepted == null ? false : accepted,
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

  @override
  Widget build(BuildContext context) {
    print('_QuestionState.build');
    //
    if (this.isBusy) {
      return WitsOverflowScaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WitsOverflowScaffold(
      body: Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              /// question title and body
              /// votes, up-vote and down-vote
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1,
                            color: Color.fromRGBO(228, 230, 232, 1.0)),
                      ),
                    ),
                    // padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                    child: Row(
                      children: <Widget>[
                        /// up vote button, down vote button
                        /// number of votes
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              color: Color.fromRGBO(214, 217, 220, 0.2),
                              child: Column(
                                // mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      this.voteQuestion(value: 1);
                                    },
                                    style: TextButton.styleFrom(
                                      minimumSize: Size(0, 0),
                                      padding: EdgeInsets.all(0.5),
                                      // backgroundColor: Colors.black12,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/caret_up.svg',
                                      semanticsLabel: 'Feed button',
                                      placeholderBuilder: (context) {
                                        return Icon(Icons.error,
                                            color: Colors.deepOrange);
                                      },
                                      height: 12.5,
                                    ),
                                  ),
                                  Text(
                                    this.questionVotes!.docs.length.toString(),
                                    style: TextStyle(
                                        // backgroundColor: Colors.black12,
                                        // fontSize: 20,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      this.voteQuestion(value: -1);
                                    },
                                    style: TextButton.styleFrom(
                                      minimumSize: Size(0, 0),
                                      padding: EdgeInsets.all(0.5),
                                      // backgroundColor: Colors.black12,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/caret_down.svg',
                                      semanticsLabel: 'Feed button',
                                      placeholderBuilder: (context) {
                                        return Icon(Icons.error,
                                            color: Colors.deepOrange);
                                      },
                                      height: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// question title
                        Expanded(
                          child: Container(
                            // color: Colors.black12,
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              this.getQuestionTitle(),
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                // fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                              softWrap: true,
                            ),
                          ),
                        ),

                        // Expanded(
                        //   child: Row(
                        //     children: <Widget>[
                        //       // date posted
                        //       Text(
                        //         this.question!.get('createAt').toString(),
                        //       ),
                        //
                        //       Text(
                        //         this.questionUser!.get('displayName').toString(),
                        //       ),
                        //       // user information
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  /// question body
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color.fromARGB(100, 214, 217, 220),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(15),
                    child: Text(
                      this.getQuestionBody(),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.,
                      children: [
                        // share button
                        TextButton.icon(
                          icon: Icon(Icons.favorite),
                          label: Text(
                            "Favourite",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () => {this._addFavouriteQuestion()},
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, 0),
                            padding: EdgeInsets.all(1),
                            // backgroundColor: Colors.black12,
                            primary: Color.fromRGBO(32, 141, 149, 1),
                          ),
                        ),

                        // edit button
                        // TextButton(
                        //   child: Text(
                        //     "Edit",
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        //   onPressed: (){
                        //     print("[QUESTION EDIT BUTTON PRESSED]");
                        //   },
                        //   style: TextButton.styleFrom(
                        //     minimumSize: Size(0, 0),
                        //     padding: EdgeInsets.all(1),
                        //     primary: Color.fromRGBO(32, 141, 149, 1.0),
                        //     // backgroundColor: Colors.black12,

                        //   ),
                        // ),

                        // // follow button
                        // TextButton(
                        //   child: Text(
                        //     "Follow",
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //     ),
                        //   ),
                        //   onPressed: (){
                        //     print("[QUESTION FOLLOW BUTTON PRESSED]");
                        //   },
                        //   style: TextButton.styleFrom(
                        //     minimumSize: Size(0, 0),
                        //     padding: EdgeInsets.all(1),
                        //     // backgroundColor: Colors.black12,
                        //     primary: Color.fromRGBO(32, 141, 149, 1.0),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  /// user who asked question
                  Container(
                    color: Color.fromRGBO(242, 249, 255, 1),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // user information
                        Container(
                          child: Row(
                            children: [
                              VerticalDivider(width: 5),
                              // user avatar image
                              ClipOval(
                                  child: Image(
                                      height: 25,
                                      width: 25,
                                      //image: AssetImage('assets/images/default_avatar.png'))
                                      image: NetworkImage(FirebaseAuth
                                          .instance.currentUser!.photoURL!))),

                              VerticalDivider(width: 10),

                              // user information (display name, metadata)
                              Column(
                                children: [
                                  // user display name
                                  Text(this.questionUser!.get('displayName'),
                                      style: TextStyle(
                                        color: Colors.blue,
                                      )),
                                  // user metadata
                                  Row(
                                    children: [],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // datetime
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'asked',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).disabledColor
                                    // backgroundColor: Colors.black12,
                                    ),
                              ),
                              Text(
                                formatDateTime(
                                    DateTime.fromMillisecondsSinceEpoch((this
                                            .question!
                                            .get('createdAt') as Timestamp)
                                        .millisecondsSinceEpoch)),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).disabledColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// user who updated question
                  Container(),
                ],
              ),

              // divider
              // Divider(),

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
                      '${this.questionAnswers!.docs.length.toString()} answers',
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
                                this.question!.id,
                                this.question!.get('title'),
                                this.question!.get('body'));
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
