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

//ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  String? module;
  final _firestore;
  final _auth;

  HomeScreen({Key? key, this.module, firestore, auth})
      : this._firestore =
            firestore == null ? FirebaseFirestore.instance : firestore,
        this._auth = auth == null ? FirebaseAuth.instance : auth,
        super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> questions;
  late RecentActivityTab recentActivityTab;
  late FavouritesTab favouritesTab;
  late MyPostsTab myPostsTab;
  WitsOverflowData witsOverflowData = WitsOverflowData();
  @override
  void initState() {
    print('HOME SCREEN: initState');
    super.initState();
    this
        .witsOverflowData
        .initialize(firestore: this.widget._firestore, auth: this.widget._auth);

    this.recentActivityTab = RecentActivityTab(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
    );

    this.favouritesTab = FavouritesTab(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
    );

    this.myPostsTab = MyPostsTab(
      firestore: this.widget._firestore,
      auth: this.widget._auth,
    );
    // questions = this.witsOverflowData.fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    print('[HOME SCREEN: build]');
    return WitsOverflowScaffold(
      body: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              color: Colors.black,
              icon: Icon(Icons.notifications),
              onPressed: () {
                //implement this
              },
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
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
              this.recentActivityTab,
              this.favouritesTab,
              this.myPostsTab,
            ],
          ),
        ),
      ),
    );
  }
}
