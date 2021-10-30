// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:flutter/material.dart';

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

/// helper function to add responsive
double getContainerWidth({required double width, double maxWidth = 720}) {
  // mobile phones
  late double w;
  if (width <= 600) {
    w = width * 97.5 / 100;
  } else if (600 < width && width <= 768) {
    w = min(width * 95 / 100, 720);
  } else if (768 < width && width <= 992) {
    w = min(width * 90 / 100, maxWidth);
  } else if (992 < width && width <= 1200) {
    w = min(width * 85 / 100, maxWidth);
  } else {
    w = min(width * 80 / 100, maxWidth);
  }
  return w;
}
