import 'package:flutter/material.dart';
import 'widgets/Gridentify.dart';
import 'storage/Highscore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gridentify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: Color(0xffffffff),
        primaryColor: Color(0xffeeeeee)
      ),
      home: Gridentify(new HighScoreStorage()),
    );
  }
}
