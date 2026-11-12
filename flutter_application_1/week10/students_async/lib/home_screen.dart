import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Data Arrives Later')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => _open(context, const StudentsScreen()),
              child: const Text('By hand'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(context, const StudentsFutureScreen()),
              child: const Text('FutureBuilder'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(context, const CountdownScreen()),
              child: const Text('Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
