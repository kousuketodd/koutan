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

TODO:
fix items going away when switching tabs
 */

