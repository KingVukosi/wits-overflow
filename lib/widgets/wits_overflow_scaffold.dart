import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/side_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wits_overflow/screens/user_info_screen.dart';

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
                    margin: EdgeInsets.only(right: 20, top: 4.5),
                    width: 250,
                    child: TextField(
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
                  Container(
                    margin: EdgeInsets.only(right: 30),
                    child: BackButton(
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                      child: Text(
                        FirebaseAuth.instance.currentUser!.displayName!,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserInfoScreen()),
                        );
                      }),
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
                        image: DecorationImage(
                            image: NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!),
                            fit: BoxFit.contain),
                      ),
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
                    margin: EdgeInsets.only(right: 250, top: 4.5),
                    width: 250,
                    child: TextField(
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
                  Container(
                    margin: EdgeInsets.only(right: 30),
                    child: BackButton(
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                      child: Text(
                        FirebaseAuth.instance.currentUser!.displayName!,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserInfoScreen()),
                        );
                      }),
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
                        image: DecorationImage(
                            image: NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!),
                            fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ]),
            drawer: SideDrawer(courses: this._courses, modules: this._modules),
            body: this.body),
      );
    }
  }
}
