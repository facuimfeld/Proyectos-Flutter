import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MiUTNFRRe/pages/home.dart';
import 'package:MiUTNFRRe/pages/login.dart';

import 'package:MiUTNFRRe/utils/services.dart';

void main() => runApp(SplashScreen());

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Services serv = Services();
  bool haveProblems = false;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      loadData(context);
    });
  }

  Future<void> loadData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('usuario')) {
      dynamic res;
      String legajo = prefs.getString('usuario').toString();
      String password = prefs.getString('password').toString();
      try {
        res = await serv
            .authenticate(legajo, password)
            .timeout(const Duration(seconds: 10));
      } on TimeoutException catch (e) {
        setState(() {
          haveProblems = true;
        });
      }
      ;

      if (res == true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Login()));
      }
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png', scale: 1),
          const SizedBox(height: 5),
          const Text('MiUTN FRRe',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white)),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          //haveProblems ? showTryLater() : Container(),
        ],
      )),
    );
  }

  Widget showTryLater() {
    return SnackBar(
        content: Row(
      children: [
        Icon(Icons.cancel, color: Colors.red),
        SizedBox(width: 20),
        Text(
            'La página del sysacad no está funcionando en estos momentos, por favor volvé a intentar más tarde'),
      ],
    ));
  }
}
