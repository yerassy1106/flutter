import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Level 2 + Level 5: four states by hand, and an honest Save button.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, this.empty = false});

  /// Pass true to see the fourth state (the server has no students).
  final bool empty;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  late final FakeApi _api = FakeApi(empty: widget.empty);
  bool _saving = false; // true while save() is in flight

  @override
  void initState() {
    super.initState();
    // initState is synchronous: it calls _load() but does not await it.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return; // the user may have left during the 2 seconds
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Widget _body() {
    if (_error != null) return ErrorView(onRetry: _load);
    final students = _students;
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();
    return StudentList(students);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('By hand')),
      body: _body(),
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              // Disabled while the request is in flight: one tap, one request.
              onPressed: _saving
                  ? null
                  : () async {
                      final n = _students!.length;
                      setState(() => _saving = true);
                      try {
                        await _api.save(n);
                        // A callback, not a State method: context.mounted.
                        if (!context.mounted) return;
                        Navigator.pop(context); // only on success
                      } on StateError catch (e) {
                        if (!context.mounted) return;
                        setState(() => _saving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    },
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
    );
  }
}
