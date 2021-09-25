import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/screens/sign_in_screen.dart';
import 'package:wits_overflow/utils/authentication.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfoScreen extends StatefulWidget {
  final _firestore;
  final _auth;

  UserInfoScreen({firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  _UserInfoScreenState createState() =>
      _UserInfoScreenState(firestore: this._firestore, auth: this._auth);
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late String userId;

  int questionCount = 0;
  int answerCount = 0;
  int favoriteCount = 0;

  var authorName = "failed to retrieve author name";
  var authorEmail = "failed to retrieve author email";

  bool _isSigningOut = false;

  WitsOverflowData witsOverflowData = new WitsOverflowData();
  late var _firestore;
  late var _auth;

  _UserInfoScreenState({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
    this.userId = witsOverflowData.getCurrentUser()!.uid;
  }

  getData() async {
    this.questionCount = 0;
    this.answerCount = 0;
    this.favoriteCount = 0;

    List<Map<String, dynamic>> userQuestions =
        await witsOverflowData.fetchUserQuestions(userId: userId);
    this.questionCount = userQuestions.length;
    // await FirebaseFirestore
    //     .instance
    //     .collection('questions-2')
    //     .where("authorId", isEqualTo: this.userId)
    //     .get()
    //     .then((docs){
    //       print(docs.size);
    //       this.questionCount += docs.size;
    //     });

    // get answers that the user has posted
    List<Map<String, dynamic>> userAnswers =
        await witsOverflowData.fetchUserAnswers(userId: userId);
    this.answerCount = userAnswers.length;
    // witsOverflowData.fetchUserQuestions(userId: this.userId)

    // .then((questions) {
    //   questions.forEach((question) async {
    //     var questionId = question['id'];
    //
    //     await FirebaseFirestore.instance
    //       .collection('questions-2')
    //       .doc(questionId)
    //       .collection('answers')
    //       .get().then((docs){
    //         this.answerCount += docs.size;
    //     });
    //   });
    // });

    // get user favourite questions
    List<Map<String, dynamic>> userFavouriteQuestions =
        await witsOverflowData.fetchUserFavouriteQuestions(userId: userId);
    this.favoriteCount = userFavouriteQuestions.length;

    // await FirebaseFirestore.instance
    //     .collection('favourites-2')
    //     .doc(this.userId)
    //     .get()
    //     .then((doc) {
    //       if (doc.exists) {
    //         this.favoriteCount += (doc['favouriteQuestions'].length as int);
    //       }
    //     });
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
    witsOverflowData.initialize();
    this.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<DocumentSnapshot> user =
        FirebaseFirestore.instance.collection('users').doc(this.userId).get();

    _getUserId() {
      user.then((questionDocumentSnapshot) {
        setState(() {
          this.authorName = questionDocumentSnapshot["displayName"];
          this.authorEmail = questionDocumentSnapshot["email"];
        });
      });
    }

    _getUserId();

    return WitsOverflowScaffold(
      auth: this._auth,
      firestore: this._firestore,
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),

            // user profile image
            Container(
              width: 100,
              height: 100,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    // Change code to get profile image of user
                    image: NetworkImage(
                        witsOverflowData.getCurrentUser()!.photoURL!),
                    fit: BoxFit.fill),
              ),
            ),

            // user display name
            ListTile(
              title: Container(
                height: 40,
                child: Text(
                  "Name",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              subtitle: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(15.0),
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    authorName,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ),

            SizedBox(
              height: 20,
            ),

            // user email address
            ListTile(
              title: Container(
                height: 40,
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              subtitle: Container(
                  padding: EdgeInsets.all(15.0),
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    authorEmail,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ),

            SizedBox(
              height: 30,
            ),

            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 150,
                alignment: Alignment.center,
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "PROFILE HISTORY",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]),

            // user meta information
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 20),
                  Text("questions asked"),
                  SizedBox(height: 10),
                  Text("questions answered"),
                  SizedBox(height: 10),
                  Text("favourite courses"),
                  SizedBox(height: 10),
                ]),
                SizedBox(
                  width: 240,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 40),
                    Text(this.questionCount.toString()),
                    SizedBox(height: 10),
                    Text(this.answerCount.toString()),
                    SizedBox(height: 10),
                    Text(this.favoriteCount.toString()),
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
          ],
        ),
      ),
    );
  }
}
