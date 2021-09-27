import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/side_drawer.dart';
// ignore: must_be_immutable
class WitsOverflowScaffold extends StatelessWidget {
  late Future<List<Map<String, dynamic>>> _courses;
  late Future<List<Map<String, dynamic>>> _modules;
  FloatingActionButton? _floatingActionButton;
  final Widget body;
  WitsOverflowData witsOverflowData = new WitsOverflowData();
  late var _firestore;
  late var _auth;

  WitsOverflowScaffold(
      {required this.body,
        courses,
        modules,
        floatingActionButton,
        firestore,
        auth}) {
    this._firestore =
    firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = auth == null ? FirebaseAuth.instance : auth;
    _floatingActionButton = floatingActionButton;
    witsOverflowData.initialize(firestore: this._firestore, auth: this._auth);
    _courses = (courses == null) ? witsOverflowData.fetchCourses() : courses;
    _modules = (modules == null) ? witsOverflowData.fetchModules() : modules;
  }

  @override
  Widget build(BuildContext context) {
    if (this._floatingActionButton != null) {
      return Scaffold(
          floatingActionButton: this._floatingActionButton,
          appBar: AppBar(title: const Text('Wits Overflow'), actions: [
            VerticalDivider(
              color: Colors.transparent,
            ),
          ]),
          body: Row(children: [
            SideDrawer(courses: this._courses, modules: this._modules),
            Expanded(child: this.body)
          ]));
    } else {
      return Scaffold(
          appBar: AppBar(title: const Text('Wits Overflow'), actions: [
            VerticalDivider(
              color: Colors.transparent,
            ),
          ]),
          body: Row(children: [
            SideDrawer(courses: this._courses, modules: this._modules, firestore: this._firestore, auth: this._auth,),
            Expanded(child: this.body)
          ]));
    }
  }
}
