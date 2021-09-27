import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wits_overflow/utils/wits_overflow_data.dart';
import 'package:wits_overflow/widgets/question_summary.dart';

// ignore: must_be_immutable
class FavouritesTab extends StatefulWidget {
  late Future<List<Map<String, dynamic>>> questions;

  FavouritesTab() {
    questions = WitsOverflowData().fetchUserFavouriteQuestions(
        userId: FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  _FavouritesTabState createState() => _FavouritesTabState();
}

class _FavouritesTabState extends State<FavouritesTab> {
  // ignore: unused_field
  late bool _loading;

  @override
  void initState() {
    super.initState();

    this._loading = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
                future: widget.questions,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    this._loading = false;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 800,
                        child: GridView.builder(
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, childAspectRatio: 7 / 2),
                            shrinkWrap: true,
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic>? data =
                                  snapshot.data?[index];
                              if (data != null) {
                                return QuestionSummary(
                                    questionId: data['id'], data: data);
                              } else {
                                return SizedBox.shrink();
                              }
                            }),
                      ),
                    );
                  } else {
                    if (this._loading == true) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Text('You have not added any favourites yet.');
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
