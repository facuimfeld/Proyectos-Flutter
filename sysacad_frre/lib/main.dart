import 'package:MiUTNFRRe/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

//import 'package:sysacad_frre/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiUTN FRRe',
      theme: ThemeData(
        canvasColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
