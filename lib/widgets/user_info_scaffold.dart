import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/side_drawer.dart';

// ignore: must_be_immutable
class UserInfoScaffold extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _courses;
  Future<List<Map<String, dynamic>>> _modules;
  FloatingActionButton? _floatingActionButton;
  final Widget body;

  UserInfoScaffold({required this.body, courses, modules, floatingActionButton})
      : _floatingActionButton = floatingActionButton,
        _courses =
            (courses == null) ? WitsOverflowData().fetchCourses() : courses,
        _modules =
            (modules == null) ? WitsOverflowData().fetchModules() : modules;

  @override
  Widget build(BuildContext context) {
    if (this._floatingActionButton != null) {
      return GestureDetector(
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
                    margin: EdgeInsets.only(right: 30),
                    child: BackButton(
                      color: Colors.white,
                    ),
                  ),
                ]),
            drawer: SideDrawer(courses: this._courses, modules: this._modules),
            body: this.body),
      );
    } else {
      return GestureDetector(
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
                    margin: EdgeInsets.only(right: 30),
                    child: BackButton(
                      color: Colors.white,
                    ),
                  ),
                ]),
            drawer: SideDrawer(courses: this._courses, modules: this._modules),
            body: this.body),
      );
    }
  }
}
