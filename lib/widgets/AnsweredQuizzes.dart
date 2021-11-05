import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnsweredQuizzes extends StatefulWidget {
  late final _firestore;
  // late final _auth;

  AnsweredQuizzes({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    // this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  State<StatefulWidget> createState() {
    return _AnsweredQuizzesState();
  }
}

class _AnsweredQuizzesState extends State<AnsweredQuizzes> {
  List<Widget> children = [];

  var allQuizzes = [];
  var docIds = [];
  var allQuizzesAnswers = [];
  var usernames = [];

  late String title;
  bool _loading = true;
  late Map<String, dynamic> quiz;

  void getData() async {
    // Getting all quizzes
    CollectionReference collectionReference =
        this.widget._firestore.collection('quizzes');

    QuerySnapshot querySnapshot = await collectionReference.get();

    allQuizzes = querySnapshot.docs.map((doc) => doc.data()).toList();

    // Getting all quizzes names
    for (var snapshot in querySnapshot.docs) {
      var documentID = snapshot.id;
      docIds.add(documentID);
    }

    // Getting answers to all quizzes
    for (int i = 0; i < docIds.length; i++) {
      CollectionReference documentReference = this
          .widget
          ._firestore
          .collection('quizzes')
          .doc(docIds[i])
          .collection('answeredQuizzes');

      QuerySnapshot documentSnapshot = await documentReference.get();

      allQuizzesAnswers
          .add(documentSnapshot.docs.map((doc) => doc.data()).toList());
    }

    // Get usernames for answers
    for (int i = 0; i < allQuizzesAnswers.length; i++) {
      if (allQuizzesAnswers[i] != []) {
        // print(allQuizzesAnswers[i][0]['author'].toString() + " ");
        DocumentReference collectionReference2 = this
            .widget
            ._firestore
            .collection('users')
            .doc('YPzvhaTUcgOA4MSUaa9aUBAsdOq1');

        DocumentSnapshot querySnapshot2 = await collectionReference2.get();

        if (querySnapshot2.exists) {
          Map<String, dynamic>? data =
              querySnapshot2.data() as Map<String, dynamic>?;
          var value = data?['displayName'];
          usernames.add(value);
        }
      } else {
        usernames.add({});
      }
    }

    this.setState(() {
      title = allQuizzes[0]['title'];
      this._loading = false;
    });
  }

  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    List<String> titles = getTitles();

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                children: [
                  DropdownQuiz(
                    titles: titles,
                    title: title,
                    allQuizzes: this.allQuizzes,
                    allQuizzesAnswers: this.allQuizzesAnswers,
                    usernames: this.usernames,
                  ),
                  Column(mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: []),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to get a string of title to be used by the dropdown quiz selector
  List<String> getTitles() {
    List<String> titles = [];

    for (int i = 0; i < allQuizzes.length; i++) {
      titles.add(allQuizzes[i]['title']);
    }

    return titles;
  }
}

// Dropdown quiz selector

class DropdownQuiz extends StatefulWidget {
  late final titles;
  late final title;
  late final allQuizzes;
  late final allQuizzesAnswers;
  late final usernames;

  DropdownQuiz({
    Key? key,
    required this.titles,
    required this.title,
    required this.allQuizzes,
    required this.allQuizzesAnswers,
    required this.usernames,
  }) : super(key: key);

  @override
  State<DropdownQuiz> createState() {
    return _DropdownQuizState();
  }
}

class _DropdownQuizState extends State<DropdownQuiz> {
  late String dropdownValue = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      dropdownValue = this.widget.title;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(this.widget.usernames[1]);
    if (this._loading == true) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue!;
              print(dropdownValue);
            });
          },
          items:
              this.widget.titles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        SingleChildScrollView(
          child: Column(
              children: getChildren(this.dropdownValue, this.widget.allQuizzes,
                  this.widget.allQuizzesAnswers)),
        ),
      ],
    );
  }

  // function to repopulate available quiz answers
  List<Widget> getChildren(
      String dropdownValue, dynamic allQuizzes, dynamic allQuizzesAnswers) {
    // Get quiz
    int idx = -1;
    List<Widget> answers = [];

    // Get all answers pertaining to a certain quiz
    for (int i = 0; i < allQuizzes.length; i++) {
      if (allQuizzes[i]['title'] == dropdownValue) {
        idx = i;
        break;
      }
    }
    // Create quiz elements for each quiz answer
    for (int i = 0; i < allQuizzesAnswers[idx].length; i++) {
      answers.add(QuizElement(
          questionNumber: this.widget.usernames[idx],
          answer: allQuizzesAnswers[idx][i].toString()));
    }
    // Return list of all quiz elements
    return answers;
  }
}

// Quiz answer display elements

class QuizElement extends StatelessWidget {
  final String questionNumber;
  final String answer;

  const QuizElement({required this.questionNumber, required this.answer});

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.grey),
          color: Colors.white70),
      margin: new EdgeInsets.symmetric(vertical: 1.0),
      child: new ListTile(
        title: new Text(this.answer),
        subtitle: new Text(this.questionNumber),
      ),
    );
  }
}
