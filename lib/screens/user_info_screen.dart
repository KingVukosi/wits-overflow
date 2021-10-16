import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/screens/sign_in_screen.dart';
import 'package:wits_overflow/utils/authentication.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/user_info_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoScreen extends StatefulWidget {
  late final _firestore;
  late final _auth;

  UserInfoScreen({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
  }

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  WitsOverflowData witsOverflowData = WitsOverflowData();

  late String userId; // = this.wits!.uid;

  int questionCount = 0;
  int answerCount = 0;
  int favoriteCount = 0;

  var authorName = "failed to retrieve author name";
  var authorEmail = "failed to retrieve author email";

  bool _isSigningOut = false;

  getData() async {
    this.userId = this.witsOverflowData.getCurrentUser()!.uid;
    this.questionCount = 0;
    this.answerCount = 0;
    this.favoriteCount = 0;

    await this
        .witsOverflowData
        .fetchUserQuestions(userId: userId)
        .then((questions) {
      setState(() {
        this.questionCount += questions.length;
      });
    });

    this
        .witsOverflowData
        .fetchUserQuestions(userId: this.userId)
        .then((questions) {
      questions.forEach((question) async {
        var questionId = question['id'];
        await this
            .witsOverflowData
            .fetchQuestionAnswers(questionId)
            .then((answers) {
          setState(() {
            this.answerCount += answers == null ? 0 : answers.length;
          });
        });
      });
    });

    await this
        .witsOverflowData
        .fetchUserFavouriteQuestions(userId: userId)
        .then((questions) {
      // if (doc.exists) {
      setState(() {
        this.favoriteCount += questions.length;
      });
      // }
    });
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);
    this.getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    authorName = this.witsOverflowData.getCurrentUser()!.displayName!;
    authorEmail = this.witsOverflowData.getCurrentUser()!.email!;

    late var image;
    if (this.widget._auth.currentUser?.photoURL == null) {
      image = ExactAssetImage('assets/images/default_avatar.png');
    } else {
      image = NetworkImage(this.widget._auth.currentUser?.photoURL!);
    }

    return UserInfoScaffold(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 700,
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  width: 700,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 0.3,
                    ),
                    // borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.only(
                      top: 10.0, left: 20, right: 20, bottom: 10),
                  child: Text(
                    "PERSONAL INFORMATION",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(right: 100, top: 70, left: 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: image, fit: BoxFit.fill),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 40,
                          width: 100,
                          child: Text(
                            "Name",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                            //alignment: Alignment.center,
                            padding: EdgeInsets.only(
                                top: 17, bottom: 5, left: 10, right: 10),
                            height: 50,
                            width: 290,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.3,
                              ),
                              //borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              authorName,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          height: 40,
                          width: 100,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                top: 17, bottom: 5, left: 10, right: 10),
                            height: 50,
                            width: 290,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 0.3,
                              ),
                            ),
                            child: Text(
                              authorEmail,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      Container(
                        width: 700,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 0.3,
                          ),
                          //borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 10),
                        child: Text(
                          "PROFILE HISTORY",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          Container(
                            padding: EdgeInsets.only(left: 0),
                            child: Text(
                              "questions asked",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.only(left: 0),
                            child: Text(
                              "questions answered",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.only(left: 0),
                            child: Text(
                              "favourite courses",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ]),
                    SizedBox(
                      width: 240,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 50),
                        Text(
                          this.questionCount.toString(),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          this.answerCount.toString(),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          this.favoriteCount.toString(),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 30),
                _isSigningOut
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          icon: Icon(Icons.power_settings_new_outlined),
                          label: Text("logout"),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isSigningOut = true;
                            });
                            await Authentication.signOut(context: context);
                            setState(() {
                              _isSigningOut = false;
                            });
                            Navigator.of(context)
                                .pushReplacement(_routeToSignInScreen());
                          },
                        ),
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
