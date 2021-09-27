import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wits_overflow/screens/module_questions_screen.dart';
import 'package:wits_overflow/screens/post_question_screen.dart';
import 'package:wits_overflow/screens/user_info_screen.dart';

class SideDrawer extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> courses;
  final Future<List<Map<String, dynamic>>> modules;

  final _firestore;
  final _auth;

  SideDrawer({required this.courses, required this.modules, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth;

  @override
  Widget build(BuildContext context) {
    late ImageProvider image;
    if (this._auth.currentUser?.photoURL == null) {
      image = ExactAssetImage('assets/images/default_avatar.png');
    } else {
      image = NetworkImage(this._auth.currentUser?.photoURL!);
    }
    return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: Drawer(child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 40, left: 10, right: 10, bottom: 10),
                        child: GestureDetector(
                            onTap: () => {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserInfoScreen())),
                                },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            // Change code to get profile image of user
                                            image: image,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Welcome, " +
                                              this
                                                  ._auth
                                                  .currentUser!
                                                  .displayName!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text("Student",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .disabledColor))
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.start,
                                  ),
                                )
                              ],
                            )),
                      ),
                      Divider(color: Colors.grey[200], height: 1),
                      Container(
                        child: ListTile(
                          leading: Icon(Icons.home),
                          title: Text('Home'),
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen())),
                          },
                        ),
                      ),
                      Divider(color: Colors.grey[200], height: 1),
                      Container(
                        child: ListTile(
                          leading: Icon(Icons.post_add_outlined),
                          title: Text('Post Question'),
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PostQuestionScreen())),
                          },
                        ),
                      ),
                      Divider(color: Colors.grey[300], height: 1),
                      FutureBuilder<List<Map<String, dynamic>>>(
                          future: courses,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data?.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic>? courseData =
                                        snapshot.data?[index];

                                    if (courseData != null) {
                                      return ExpansionTile(
                                        title: Text(courseData['name']),
                                        children: [
                                          // Modules
                                          FutureBuilder<
                                                  List<Map<String, dynamic>>>(
                                              future: modules,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          snapshot.data?.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        Map<String, dynamic>?
                                                            moduleData =
                                                            snapshot
                                                                .data?[index];

                                                        if (moduleData !=
                                                            null) {
                                                          if (moduleData[
                                                                  'courseId'] ==
                                                              courseData[
                                                                  'id']) {
                                                            return ListTile(
                                                              title: Text(
                                                                  moduleData[
                                                                      'name']),
                                                              onTap: () => {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            ModuleQuestionsScreen(
                                                                              moduleId: moduleData['id'],
                                                                              firestore: this._firestore,
                                                                              auth: this._auth,
                                                                            ))),
                                                              },
                                                            );
                                                          } else {
                                                            return SizedBox
                                                                .shrink();
                                                          }
                                                        } else {
                                                          return Text(
                                                              "Could not load module.");
                                                        }
                                                      });
                                                } else {
                                                  return Container();
                                                }
                                              }),
                                        ],
                                      );
                                    } else {
                                      return Text("Could not load course.");
                                    }
                                  });
                            } else {
                              return Column(
                                children: [
                                  SizedBox(height: 25),
                                  CircularProgressIndicator.adaptive(
                                      // valueColor: AlwaysStoppedAnimation<Color>(
                                      //     Colors.white)
                                      )
                                ],
                              );
                            }
                          }),
                    ],
                  )));
        })));
  }
}
