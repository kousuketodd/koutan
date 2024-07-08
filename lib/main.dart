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

TODO:
make summary page pretty
fix state setting when logging new items and deleting them

 */

