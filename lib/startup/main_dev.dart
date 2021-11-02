import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:wits_overflow/startup/wits_overflow_app.dart';

Future<void> main() async {
  await DotEnv.load(fileName: "env/.env_dev");
  runApp(WitsOverflowApp());
}
