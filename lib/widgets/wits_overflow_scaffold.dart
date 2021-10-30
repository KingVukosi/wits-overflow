import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/search_results_screen.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/side_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wits_overflow/screens/user_info_screen.dart';

// ignore: must_be_immutable
class WitsOverflowScaffold extends StatelessWidget {
  late Future<List<Map<String, dynamic>>> _courses;
  late Future<List<Map<String, dynamic>>> _modules;
  // late FloatingActionButton? _floatingActionButton;

  WitsOverflowData witsOverflowData = WitsOverflowData();
  final Widget body;

  late final _firestore;
  late final _auth;

  WitsOverflowScaffold(
      {required this.body,
      courses,
      modules,
      // floatingActionButton,
      firestore,
      auth}) {
    // this._floatingActionButton = floatingActionButton;

    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;

    this
        .witsOverflowData
        .initialize(firestore: this._firestore, auth: this._auth);

    this._courses =
        (courses == null) ? witsOverflowData.fetchCourses() : courses;
    this._modules =
        (modules == null) ? witsOverflowData.fetchModules() : modules;
  }
  @override
  Widget build(BuildContext context) {
    late var image;
    if (this._auth.currentUser?.photoURL == null) {
      image = ExactAssetImage('assets/images/default_avatar.png');
    } else {
      image = NetworkImage(this._auth.currentUser?.photoURL!);
    }
    // if (this._floatingActionButton != null) {
    //   return GestureDetector(
    //     onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
    //     child: Scaffold(
    //         appBar: AppBar(
    //             elevation: 1,
    //             title: Text(
    //               'Wits Overflow',
    //               style: TextStyle(
    //                 fontSize: 15,
    //                 color: Colors.white,
    //               ),
    //             ),
    //             actions: [
    //               Container(
    //                 margin: EdgeInsets.only(right: 20, top: 4.5),
    //                 width: 250,
    //                 child: TextField(
    //                   decoration: InputDecoration(
    //                     filled: true,
    //                     fillColor: Colors.white,
    //                     prefixIcon: Icon(Icons.search),
    //                     border: UnderlineInputBorder(
    //                       borderRadius: BorderRadius.circular(40),
    //                     ),
    //                     hintText: "Search",
    //                   ),
    //                 ),
    //               ),
    //               Container(
    //                 margin: EdgeInsets.only(right: 30),
    //                 child: BackButton(
    //                   color: Colors.white,
    //                 ),
    //               ),
    //               TextButton(
    //                   child: Text(
    //                     this.witsOverflowData.getCurrentUser()!.displayName!,
    //                     style: TextStyle(color: Colors.white, fontSize: 15),
    //                   ),
    //                   onPressed: () {
    //                     Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                           builder: (context) => UserInfoScreen()),
    //                     );
    //                   }),
    //               GestureDetector(
    //                 onTap: () => {
    //                   Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                           builder: (context) => UserInfoScreen())),
    //                 },
    //                 child: Container(
    //                   width: 25,
    //                   height: 25,
    //                   margin: EdgeInsets.only(right: 10, left: 20),
    //                   decoration: BoxDecoration(
    //                     shape: BoxShape.circle,
    //                     image:
    //                         DecorationImage(image: image, fit: BoxFit.contain),
    //                   ),
    //                 ),
    //               ),
    //             ]),
    //         drawer: SideDrawer(courses: this._courses, modules: this._modules),
    //         body: Row(children: [
    //           SideDrawer(courses: this._courses, modules: this._modules),
    //           Expanded(child: this.body)
    //         ])),
    //   );
    // }
    // else {
    return MaterialApp(
      // initialRoute: '/',
      // routes: {
      //   // When navigating to the "/" route, build the FirstScreen widget.
      //   '/': (context) => const FirstScreen(),
      //   // When navigating to the "/second" route, build the SecondScreen widget.
      //   '/second': (context) => const SecondScreen(),
      // },
      home: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
                elevation: 1,
                title: Text(
                  'Wits Overflow',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 5, top: 4.5),
                    width: 250,
                    child: TextField(
                      onSubmitted: (String keyword) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return SearchResults(keyword: keyword);
                        }));
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        hintText: "Search",
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(right: 30),
                  //   child: BackButton(
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // TextButton(
                  //     child: Text(
                  //       this.witsOverflowData.getCurrentUser()!.displayName!,
                  //       style: TextStyle(color: Colors.white, fontSize: 15),
                  //     ),
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => UserInfoScreen()),
                  //       );
                  //     }),
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserInfoScreen())),
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      margin: EdgeInsets.only(right: 10, left: 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image:
                            DecorationImage(image: image, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ]),
            // drawer: SideDrawer(courses: this._courses, modules: this._modules, firestore: this._firestore, auth: this._auth,),
            body: Row(children: [
              SideDrawer(
                courses: this._courses,
                modules: this._modules,
                firestore: this._firestore,
                auth: this._auth,
              ),
              Expanded(child: this.body)
            ])),
      ),
    );
    // }
  }
}
