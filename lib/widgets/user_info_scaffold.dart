import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/side_drawer.dart';

// ignore: must_be_immutable
class UserInfoScaffold extends StatelessWidget {
  late final Future<List<Map<String, dynamic>>> _courses;
  late final Future<List<Map<String, dynamic>>> _modules;
  late final FloatingActionButton? _floatingActionButton;
  final Widget body;

  WitsOverflowData witsOverflowData = WitsOverflowData();

  late final _firestore;
  late final _auth;

  // WitsOverflowScaffold(
  //     {required this.body,
  //       courses,
  //       modules,
  //       floatingActionButton,
  //       firestore,
  //       auth}) {
  //   this._floatingActionButton = floatingActionButton;
  //
  //   this._firestore =
  //   firestore == null ? FirebaseFirestore.instance : firestore;
  //   this._auth = auth == null ? FirebaseAuth.instance : auth;
  //
  //   this
  //       .witsOverflowData
  //       .initialize(firestore: this._firestore, auth: this._auth);
  //
  //   this._courses =
  //   (courses == null) ? witsOverflowData.fetchCourses() : courses;
  //   this._modules =
  //   (modules == null) ? witsOverflowData.fetchModules() : modules;
  // }

  UserInfoScaffold(
      {required this.body,
      courses,
      modules,
      floatingActionButton,
      firestore,
      auth}) {
    this._floatingActionButton = floatingActionButton;

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
  // : _floatingActionButton = floatingActionButton,
  //   _courses =
  //       (courses == null) ? WitsOverflowData().fetchCourses() : courses,
  //   _modules =
  //       (modules == null) ? WitsOverflowData().fetchModules() : modules;{}

  @override
  Widget build(BuildContext context) {
    if (this._floatingActionButton != null) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
                leading: Container(
                  margin: EdgeInsets.only(right: 30),
                  child: BackButton(
                    color: Colors.white,
                  ),
                ),
                elevation: 1,
                title: Text(
                  'Wits Overflow',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                actions: []),
            drawer: SideDrawer(courses: this._courses, modules: this._modules),
            body: this.body),
      );
    } else {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
                leading: Container(
                  margin: EdgeInsets.only(right: 30),
                  child: BackButton(
                    color: Colors.white,
                  ),
                ),
                elevation: 1,
                title: Text(
                  'Wits Overflow',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                actions: []),
            drawer: SideDrawer(
                courses: this._courses,
                modules: this._modules,
                firestore: this._firestore,
                auth: this._auth),
            body: this.body),
      );
    }
  }
}
