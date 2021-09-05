import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/utils/authentication.dart';
import 'package:wits_overflow/widgets/google_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Material(
            type: MaterialType.transparency,
            child: Center(
                child: Container(
                    padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Image.asset(
                            'assets/images/wits_logo_transparent.png',
                            scale: 2,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Wits Overflow',
                          style: TextStyle(
                            color: const Color(0xff001b5a),
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          "Welcome to Wits Overflow.  The ultimate in high-tech question answering goodness.  Enter for all your knowledge seeking needs.",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Currently we\'re catering exclusively to Wits students (lucky you), so click the button below to sign in with your student gmail account and get started on your journey to unlimited knowledge...',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 40),
                        FutureBuilder(
                          future: Authentication.initializeFirebase(
                              context: context),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error initializing Firebase');
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return GoogleSignInButton();
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ],
                    )))));
  }
}
