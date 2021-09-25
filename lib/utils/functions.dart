import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

String toTitleCase(String string) {
  /// return a string in a title format
  String result = '';
  String c;
  for (var i = 0; i < string.length; i++) {
    if (i == 0) {
      c = capitaliseChar(string[i]);
    } else if (string.codeUnitAt(i - 1) == 32) {
      c = capitaliseChar(string[i]);
    } else {
      c = string[i];
    }
    result = result + c;
  }
  return result;
}

String capitaliseChar(String char) {
  // returns capitalised char
  String result = char;
  int code = char.codeUnitAt(0);
  if (code >= 97 && code <= 122) {
    result = String.fromCharCode(code - 32);
  }
  return result;
}

dynamic getField(Map<String, dynamic>? map, String field,
    {dynamic onError, dynamic onNull}) {
  // onError: string to return when field does not exist
  if (map == null) {
    return onNull;
  }
  try {
    return map[field] == null ? onNull : map[field];
  } catch (e) {
    return onError;
  }
}

String formatDateTime(DateTime datetime) {
  Map<int, String> months = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec'
  };
  return "${months[datetime.month]} ${datetime.day} '${datetime.year.toString().substring(2, 4)} at ${datetime.hour}:${datetime.minute}";
}

Future<void> updateQuestions() async {
  /*
  edit: matlala Reuben
  purpose: update questions in the database that yet don't have recentActivityAt field,
   */

  Future<DateTime> getQuestionRecentActivityDatetime(
      {required String questionId}) async {
    CollectionReference<Map<String, dynamic>> questionsReference =
        FirebaseFirestore.instance.collection('questions');
    DocumentSnapshot<Map<String, dynamic>> question =
        await questionsReference.doc(questionId).get();

    // updated at can be null or may not exist
    int latest =
        (question.data()!['createAt'] as Timestamp).millisecondsSinceEpoch;
    var updatedAt = question.data()!['updatedAt'];
    if (updatedAt != null) {
      int l = (updatedAt as Timestamp).millisecondsSinceEpoch;
      if (l > latest) {
        latest = l;
      }
    }

    QuerySnapshot<Map<String, dynamic>> comments = await question.reference
        .collection('comments')
        .orderBy('commentedAt', descending: true)
        .get();

    int l = comments.docs.length > 0
        ? (comments.docs.elementAt(0).data()['commentedAt'] as Timestamp)
            .millisecondsSinceEpoch
        : 0;
    if (l > latest) {
      latest = l;
    }

    QuerySnapshot<Map<String, dynamic>> answers =
        await question.reference.collection('answers').get();

    // holds the latest timestamp from the answers
    // this value can either be
    // - 'answeredAt' new answer posted
    // - 'updatedAt' update of answer
    // - 'commentedAt' (from answer's comments) new comment added to the answer

    // here in the loop, try to get answer with latest comment post
    for (var i = 0; i < answers.docs.length; i++) {
      // so far we don't have comments for answers
      // and so far the app does not allow uses to comment on a answer
      // so, this should return empty, unless we added comments to answers manually
      QuerySnapshot<Map<String, dynamic>> answerComments = await answers.docs
          .elementAt(i)
          .reference
          .collection('comments')
          .orderBy('commentedAt', descending: true)
          .get();
      List<int> d = [
        (answers.docs.elementAt(i).data()['answeredAt'] as Timestamp)
            .millisecondsSinceEpoch,
      ];

      if (answers.docs.elementAt(i).data()['updatedAt'] != null) {
        d.add((answers.docs.elementAt(i).data()['updatedAt'] as Timestamp)
            .millisecondsSinceEpoch);
      }

      if (answerComments.docs.length > 0) {
        d.add((answerComments.docs.first.data()['commentedAt'] as Timestamp)
            .millisecondsSinceEpoch);
        d.add((answerComments.docs.first.data()['createdAt'] as Timestamp)
            .millisecondsSinceEpoch);
      }

      d.sort();
      if (d.last > latest) {
        latest = d.last;
      }
    }
    return Future.value(DateTime.fromMillisecondsSinceEpoch(latest));
  }

  QuerySnapshot<Map<String, dynamic>> questions =
      await FirebaseFirestore.instance.collection('questions').get();
  for (var i = 0; i < questions.docs.length; i++) {
    DateTime latestDatetime = await getQuestionRecentActivityDatetime(
        questionId: questions.docs.elementAt(i).id);
    questions.docs
        .elementAt(i)
        .reference
        .update({'recentActivityAt': latestDatetime}).then((value) {
      print('[then: UPDATED QUESTION]');
    }).whenComplete(() {
      print('[whenComplete:UPDATED QUESTION: INSERTED recentActivityAt FILED]');
    }).catchError((e) {
      print('[ERROR OCCURRED WHILE UPDATING QUESTIONS]');
    });
  }
}

/// function to show notification to user
void showNotification(context, message, {type = 'primary'}) {
  Color? bgColor;
  if (type == 'error') {
    bgColor = Colors.red;
  } else if (type == 'warning') {
    bgColor = Colors.orange;
  } else {
    bgColor = Colors.blue;
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: bgColor,
  ));
}

const Map COLLECTIONS = {
  'questions': 'questions-2',
  'favourites': 'favorites-2',
  'courses': 'courses-2',
  'modules': 'modules-2',
  'users': 'users',
};

int countVotes(List<Map<String, dynamic>> votes) {
  int count = 0;
  for (int i = 0; i < votes.length; i++) {
    count += votes[i]['value'] as int;
  }
  return count;
}

// final map STYLES = {
//     'background_colour':
// }
