import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/side_drawer.dart';

// ignore: must_be_immutable
class WitsOverflowScaffold extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _courses;
  Future<List<Map<String, dynamic>>> _modules;
  FloatingActionButton? _floatingActionButton;
  final Widget body;

  WitsOverflowScaffold(
      {required this.body, courses, modules, floatingActionButton})
      : _floatingActionButton = floatingActionButton,
        _courses =
            (courses == null) ? WitsOverflowData().fetchCourses() : courses,
        _modules =
            (modules == null) ? WitsOverflowData().fetchModules() : modules;

  @override
  Widget build(BuildContext context) {
    if (this._floatingActionButton != null) {
      return Scaffold(
          floatingActionButton: this._floatingActionButton,
          appBar: AppBar(title: const Text('Wits Overflow'), actions: [
            // IconButton(
            //   icon: Image.network(
            //     FirebaseAuth.instance.currentUser!.photoURL!
            //   ),
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('This is a snackbar')));
            //   }),
            VerticalDivider(
              color: Colors.transparent,
            ),
          ]),
          drawer: SideDrawer(courses: this._courses, modules: this._modules),
          body: this.body);
    } else {
      return Scaffold(
          appBar: AppBar(title: const Text('Wits Overflow'), actions: [
            // IconButton(
            //   icon: Image.network(
            //     FirebaseAuth.instance.currentUser!.photoURL!
            //   ),
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('This is a snackbar')));
            //   }),
            VerticalDivider(
              color: Colors.transparent,
            ),
          ]),
          drawer: SideDrawer(courses: this._courses, modules: this._modules),
          body: this.body);
    }
  }
}
