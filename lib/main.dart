import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:koutan/firebase_options.dart';
import 'myapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
/*
LOG: 

made folder and items readable from firebase
made folders and items writable to firebase
tabs and items readable from firebase
items stay when switching tabs

TODO:
add monthly logs to database
for a month's log, include:
each category has its own box
in each box, include:
  ITEM NAME
  UNIT PRICE
  # REMAINING
  # REMAINING * UNIT PRICE
  COST FOR WHOLE CATEGORY

THE LOG WILL HAVE THE TOTAL PRICE FOR EVERY CATEGORY AT THE BOTTOM
 */

