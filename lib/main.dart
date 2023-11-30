import 'package:flutter/material.dart';
import 'package:koutan/add_sub_popup.dart';
import 'package:provider/provider.dart';
import 'myapp.dart';


void main() {
  runApp(ChangeNotifierProvider(
    create:(context) => LogController(),
    child: MyApp()));
}
