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

made log summary, reads from database

made logs writable

finished image upload

app works with new db layout

Negative logs are properly handled 

Clear log list when submitting

Log writes unique logs for the same item. Either update the item in the log category, or have summary page merge them (FIXED)
TODO:
    Fix master total being stuck at 0
 */

