import 'package:flutter/material.dart';
import 'pages/homepage.dart';

void main() {
  runApp(Typesetting());
}

class Typesetting extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'typesetting',
      home: Scaffold(
        body: Homepage(),
      ),
    );
  }
}
