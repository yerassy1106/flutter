import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const StudentsApp());
}

class StudentsApp extends StatelessWidget {
  const StudentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'students_async',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
