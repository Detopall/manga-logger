import 'package:flutter/material.dart';
import 'package:manga_logger/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Poppins"),
      title: 'Manga Logger',
      home: const LoginPage(),
    );
  }
}
