// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/favourites_tab.dart';
import 'package:wits_overflow/widgets/my_posts_tab.dart';
import 'package:wits_overflow/widgets/recent_activity_tab.dart';
import 'package:wits_overflow/widgets/wits_overflow_scaffold.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  String? module;
  late var _firestore;
  late var _auth;
  HomeScreen({Key? key, this.module, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth,
        super(key: key);

  @override
  HomeScreenState createState() =>
      HomeScreenState(firestore: this._firestore, auth: this._auth);
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> questions;

  WitsOverflowData witsOverflowData = new WitsOverflowData();
  late var _firestore;
  late var _auth;

  HomeScreenState({firestore, auth}) {
    this._firestore =
        firestore == null ? FirebaseFirestore.instance : firestore;
    this._auth = firestore == null ? FirebaseAuth.instance : auth;
    this
        .witsOverflowData
        .initialize(firestore: this._firestore, auth: this._auth);
  }

  @override
  void initState() {
    super.initState();
  }

  void getData() {
    questions = witsOverflowData.fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return WitsOverflowScaffold(
      auth: this._auth,
      firestore: this._firestore,
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  tabs: [
                    Tab(text: 'Recent Activity'),
                    Tab(text: 'Favourites'),
                    Tab(text: 'My Posts'),
                  ],
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              RecentActivityTab(),
              FavouritesTab(),
              MyPostsTab(
                firestore: this._firestore,
                auth: this._auth,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
