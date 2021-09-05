// import 'package:cloud_firestore/cloud_firestore.dart';
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

  HomeScreen({Key? key, this.module}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> questions;

  @override
  void initState() {
    super.initState();

    questions = WitsOverflowData().fetchQuestions();

    //WitsOverflowData().seedDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return WitsOverflowScaffold(
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
              MyPostsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
