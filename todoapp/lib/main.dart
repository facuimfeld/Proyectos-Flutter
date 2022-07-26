import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todoapp/controllers/taskcontroller.dart';
import 'package:todoapp/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
