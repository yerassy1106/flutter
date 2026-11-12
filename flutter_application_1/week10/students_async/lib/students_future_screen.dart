import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Level 3: the same screen with FutureBuilder, done right.
class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();

  // Assigned in initState, and replaced only in _retry. It is `late` but not
  // `final` because Retry is the one place a new Future is allowed.
  late Future<List<Student>> _future;

  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  // The only place besides initState where a new Future may be created.
  void _retry() {
    setState(() => _future = _api.fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FutureBuilder'),
        actions: [
          const Text('Compact'),
          Switch(
            value: _compact,
            onChanged: (v) => setState(() => _compact = v),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future, // the field, never a call
        builder: (context, snapshot) {
          // hasError goes first, otherwise an error looks like a spinner.
          if (snapshot.hasError) return ErrorView(onRetry: _retry);
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const <Student>[];
          if (list.isEmpty) return const EmptyView();
          return StudentList(list, compact: _compact);
        },
      ),
    );
  }
}
